# Se indica el ID de salida del RG
output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

# Se indica el ID de la VM
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

# Se indica el ID de la VM
output "vm_ip" {
  value = azurerm_linux_virtual_machine.vm.ip_address
}