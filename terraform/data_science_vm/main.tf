# Create a Linux virtual machine with the Data Science Ubuntu image
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}VM"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.nic_id]
  size                  = var.vm_size
  computer_name         = "${var.prefix}VM"
  admin_username        = var.admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key_openssh
  }

  os_disk {
    name                 = "${var.prefix}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "microsoft-dsvm"
    offer     = "ubuntu-1804"
    sku       = "1804"
    version   = "latest"
  }
}
