# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Import standard VM module
module "vm" {
  source = "./standard_vm"
  count  = var.dsvm ? 0 : 1

  prefix              = var.prefix
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  nic_id              = azurerm_network_interface.nic.id
  public_key_openssh  = tls_private_key.admin.public_key_openssh
}

# Create admin user SSH key
resource "tls_private_key" "admin" {
  # algorithm   = "ECDSA"
  # ecdsa_curve = "P256"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Create a resource group
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
resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
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

# Create a data disk
resource "azurerm_managed_disk" "disk" {
  name                = "${var.prefix}DataDisk"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  count = var.data_disk_size_gb > 0 ? 1 : 0
}

# Attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  depends_on         = [module.vm]
  managed_disk_id    = azurerm_managed_disk.disk[count.index].id
  virtual_machine_id = [module.vm.id]
  lun                = "2"
  caching            = "ReadWrite"

  count = var.data_disk_size_gb > 0 ? 1 : 0
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [module.vm]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

resource "local_file" "admin_private_key" {
  filename        = "../ansible/admin_id_rsa.pem"
  file_permission = "0600"
  content         = tls_private_key.admin.private_key_pem
}

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

resource "local_file" "ansible_variables" {
  filename        = "../ansible/terraform_vars.yaml"
  file_permission = "0644"
  content         = <<-DOC
    ---
    data_disk_size_gb: ${var.data_disk_size_gb}
    DOC
}
