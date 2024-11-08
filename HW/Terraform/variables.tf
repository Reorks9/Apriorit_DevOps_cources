variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "TerraformRG"
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "TerraformVNet"
}

variable "subnet1_name" {
  description = "Name of the subnet1"
  type        = string
  default     = "TerraformSubnet1"
}

variable "subnet2_name" {
  description = "Name of the subnet2"
  type        = string
  default     = "TerraformSubnet2"
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet1_prefix" {
  description = "Address prefix for the Subnet1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_prefix" {
  description = "Address prefix for the Subnet2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "nsg_name" {
  description = "Name of the security group"
  type        = string
  default     = "TerraformSG"
}

variable "allowed_source_address" {
  description = "Allowed source address prefix for the NSG rule"
  type        = list
  default     = ["93.170.44.89", "92.119.220.144/29"]
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "TerraformVM"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "adminuser"
}

# Это добро не сработало.. якобы через переменную нельзя указывать username в main.tf
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}