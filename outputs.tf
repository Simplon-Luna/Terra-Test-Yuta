output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = "${element(split(",", lookup(azurerm_public_ip.mypublicip.id, azurerm_public_ip.mypublicip2.id, "")), 0)}"
}
