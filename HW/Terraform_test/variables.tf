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

variable "address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
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
  default     = "azureuser"
}
