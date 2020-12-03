variable "vm_size" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "nic_id" {
  type        = string
  description = "ID of a Network Interface Connection"
}

variable "public_key_openssh" {
  type        = string
  description = "Public SSH key for the admin user"
}
