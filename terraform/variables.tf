variable "vm_size" {
  type    = string
  default = "Standard_B2s"
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
  type = string
  default = "StandardSSD_LRS"
  validation {
    condition     = can(contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.storage_type))
    error_message = "The storage type must be one of Standard_LRS, StandardSSD_LRS and Premium_LRS."
  }
}

variable "data_disk_size_gb" {
  type    = number
  default = 0
}
