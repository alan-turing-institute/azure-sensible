variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "ssh_addresses" {
  type    = list
  default = ["*"]
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "prefix" {
  type    = string
  default = "my"
}

variable "admin_username" {
  type    = string
  default = "ansible_admin"
}

variable "storage_type" {
  type    = string
  default = "StandardSSD_LRS"
  validation {
    condition     = can(contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.storage_type))
    error_message = "The storage type must be one of Standard_LRS, StandardSSD_LRS and Premium_LRS."
  }
}

variable "data_disk_size_gb" {
  type    = number
  default = 0
  validation {
    condition     = var.data_disk_size_gb >= 0
    error_message = "The data disk size must be a positive integer or 0."
  }
}

variable "vm_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
