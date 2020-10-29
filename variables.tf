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

variable "admin_ssh_public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "admin_ssh_private_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}
