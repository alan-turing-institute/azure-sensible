# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

# Declare Azure provider
provider "azurerm" {
  features {}
}

# Create admin user SSH key
resource "tls_private_key" "admin" {
  # algorithm   = "ECDSA"
  # ecdsa_curve = "P256"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}RG"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "${var.prefix}PublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create SSH NSG rule
resource "azurerm_network_security_rule" "ssh_prefixes" {
  count = length(var.ssh_addresses) > 1 ? 1 : 0

  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_addresses #tfsec:ignore:AZU001
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_security_rule" "ssh_prefix" {
  #tfsec:ignore:AZU017
  count = length(var.ssh_addresses) > 1 ? 0 : 1

  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.ssh_addresses[0] #tfsec:ignore:AZU001
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}NIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}NICConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Associate network interface with network security group
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}VM"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size
  computer_name         = "${var.prefix}VM"
  admin_username        = var.admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.admin.public_key_openssh
  }

  os_disk {
    name                 = "${var.prefix}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_type
  }

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }
}

# Create a data disk
resource "azurerm_managed_disk" "disk" {
  name                = "${var.prefix}DataDisk"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  storage_account_type = var.storage_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  count = var.data_disk_size_gb > 0 ? 1 : 0
}

# Attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  managed_disk_id    = azurerm_managed_disk.disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = "0"
  caching            = "ReadWrite"

  count = var.data_disk_size_gb > 0 ? 1 : 0
}

# Register public IP address to write to Ansible inventory
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.vm]
}

# Print public IP address
output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

# Write admin account private key to a file
resource "local_file" "admin_private_key" {
  filename        = "../ansible/admin_id_rsa.pem"
  file_permission = "0600"
  content         = tls_private_key.admin.private_key_pem
}

# Create Ansible inventory for the defined virtual machine
resource "local_file" "ansible_inventory" {
  filename        = "../ansible/inventory.yaml"
  file_permission = "0644"
  content         = <<-DOC
    ---
    all:
      hosts:
        vm:
          ansible_host: ${data.azurerm_public_ip.ip.ip_address}
          ansible_user: ${var.admin_username}
          ansible_ssh_private_key_file: ${local_file.admin_private_key.filename}
    DOC
}

# Write variables needed by Ansible to a YAML file
resource "local_file" "ansible_variables" {
  filename        = "../ansible/terraform_vars.yaml"
  file_permission = "0644"
  content         = <<-DOC
    ---
    data_disk_size_gb: ${var.data_disk_size_gb}
    DOC
}
