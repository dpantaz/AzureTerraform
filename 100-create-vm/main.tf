terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.21.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = local.location
}

module "frontend_vms" {
  source = "../modules/azure_vm"

  #Define the number of frontend VMs 
  instances = 1

  vnet_name                = local.vnet_name
  location                 = local.location
  resource_group_name      = azurerm_resource_group.rg.name
  subnet_name              = var.frontend_subnet
  vm_name                  = var.frontend_vm_prefix
  vnet_resource_group_name = local.vnet_resource_group_name
  os_type                  = "windows"
  avset_name               = null
  vm_size                  = var.vm_size
  admin_username           = var.admin_username
  admin_password           = var.admin_password

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "backend_vms" {
  source = "../modules/azure_vm"

  #Define the number of backend VMs
  instances = 1

  vnet_name                = local.vnet_name
  location                 = local.location
  resource_group_name      = azurerm_resource_group.rg.name
  subnet_name              = var.backend_subnet
  vm_name                  = var.backend_vm_prefix
  vnet_resource_group_name = local.vnet_resource_group_name
  os_type                  = "linux"
  avset_name               = null
  vm_size                  = var.vm_size
  admin_username           = var.admin_username
  admin_password           = var.admin_password

  depends_on = [
    azurerm_resource_group.rg
  ]
}
