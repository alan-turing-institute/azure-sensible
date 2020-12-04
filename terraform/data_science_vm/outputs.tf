data "azurerm_virtual_machine" "vm_id" {
  name                = azurerm_linux_virtual_machine.vm.name
  resource_group_name = var.resource_group_name
}

output "vm_id" {
  value       = data.azurerm_virtual_machine.vm_id.id
  description = "VM ID"
}
