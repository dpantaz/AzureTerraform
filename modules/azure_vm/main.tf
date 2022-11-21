# Project resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#refer to an existing subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

#Create network interface cards
resource "azurerm_network_interface" "nic" {
  count               = var.instances
  name                = "${var.vm_name}${format("%d", count.index + 1)}-nic-int-01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#If avset_name is not null, create an availability set, otherwise, do nothing
resource "azurerm_availability_set" "as" {
  count                        = var.avset_name != null ? 1 : 0
  name                         = var.avset_name
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                 = var.os_type == "windows" ? var.instances : 0
  name                  = "${var.vm_name}${format("%d", count.index + 1)}"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  availability_set_id   = var.avset_name != null ? element(concat(azurerm_availability_set.as.*.id, [""]), 0) : null
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.vm_name}${format("%d", count.index + 1)}-os-01"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

}

resource "azurerm_linux_virtual_machine" "VM" {
  count                           = var.os_type == "linux" ? var.instances : 0
  name                            = "${var.vm_name}${format("%d", count.index + 1)}"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [element(azurerm_network_interface.nic.*.id, count.index)]
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = "false"
  availability_set_id             = var.avset_name != null ? element(concat(azurerm_availability_set.as.*.id, [""]), 0) : null

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.vm_name}${format("%d", count.index + 1)}-os-01"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}
