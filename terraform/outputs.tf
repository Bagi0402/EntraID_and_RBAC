output "tenant_domain" {
  value = var.tenant_domain
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "developers_group_id" {
  value = azuread_group.developers.id
}

output "operations_group_id" {
  value = azuread_group.operations.id
}

output "readonly_group_id" {
  value = azuread_group.readonly.id
}

output "web_app_client_id" {
  value = azuread_application.web_app.client_id
}