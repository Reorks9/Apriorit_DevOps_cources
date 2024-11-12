provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.address_space]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "subnet" {
  name                 = "Terraformsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

# ssh 
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_source_address
    destination_address_prefix = "*"
  }

# http 
  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowed_source_address
    destination_address_prefix = "*"
  }
}

# Create an Availability Set
resource "azurerm_availability_set" "avset" {
  name                = "myAvailabilitySet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
  platform_update_domain_count = 5
  managed             = true
}

# Create a public IP for load balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "TerraformPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Load balancer
resource "azurerm_lb" "lb" {
  name                = "TerraformLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend address pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "TerraformBackendPool"
}

# load balancer health probe
resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "httpProbe"
  protocol            = "Tcp"
  port                = 80
}

# load balancer rule for HTTP
resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "httpRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

# network interfaces for VMs
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "myNIC-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate each NIC with the Load Balancer Backend Pool (with ip_configuration_name)
resource "azurerm_network_interface_backend_address_pool_association" "example_lb_nic_association" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
}

# Load Balancer NAT Rules
resource "azurerm_lb_nat_rule" "ssh_nat_rule_vm1" {
  name                           = "SSH-NAT-Rule-VM1"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "PublicIPAddress"
  protocol                       = "Tcp"
  frontend_port                  = 2201
  backend_port                   = 22
}

resource "azurerm_lb_nat_rule" "ssh_nat_rule_vm2" {
  name                           = "SSH-NAT-Rule-VM2"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "PublicIPAddress"
  protocol                       = "Tcp"
  frontend_port                  = 2202
  backend_port                   = 22
}

# Associate NAT rule with NIC for VM1
resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_vm1" {
  network_interface_id      = azurerm_network_interface.nic[0].id
  ip_configuration_name     = "internal"
  nat_rule_id               = azurerm_lb_nat_rule.ssh_nat_rule_vm1.id
}

# Associate NAT rule with NIC for VM2
resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_vm2" {
  network_interface_id      = azurerm_network_interface.nic[1].id
  ip_configuration_name     = "internal"
  nat_rule_id               = azurerm_lb_nat_rule.ssh_nat_rule_vm2.id
}

# Associate NSG with each NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                 = 2
  network_interface_id  = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create the VMs
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "${var.vm_name}-${count.index + 1}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  availability_set_id   = azurerm_availability_set.avset.id
  
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

    admin_ssh_key {
    username   = var.admin_username
    public_key = file("ssh1.pub")
  }

}