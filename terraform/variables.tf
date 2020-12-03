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

variable "data_disk_size_gb" {
  type    = number
  default = 0
}

variable "dsvm" {
  type    = bool
  default = false
}
