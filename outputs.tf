output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.mypublicip.id
}

output "public_ip_address2" {
  value =  azurerm_public_ip.mypublicip2.id
}