# ── RESOURCE GROUP ──
resource "azurerm_resource_group" "main" {
  name     = "rg-entraid-rbac-project"
  location = var.location
}

# ── ENTRA ID USERS ──
resource "azuread_user" "dev_user" {
  user_principal_name = "dev-user@${var.tenant_domain}"
  display_name        = "Rose Jack"
  password            = "TempP@ssw0rd123!"
  force_password_change = true
}

resource "azuread_user" "ops_user" {
  user_principal_name = "ops-user@${var.tenant_domain}"
  display_name        = "Charlie Chaplin"
  password            = "TempP@ssw0rd123!"
  force_password_change = true
}

resource "azuread_user" "readonly_user" {
  user_principal_name = "readonly-user@${var.tenant_domain}"
  display_name        = "Harry Potter"
  password            = "TempP@ssw0rd123!"
  force_password_change = true
}

# ── SECURITY GROUPS ──
resource "azuread_group" "developers" {
  display_name     = "Developers"
  security_enabled = true
}

resource "azuread_group" "operations" {
  display_name     = "Operations"
  security_enabled = true
}

resource "azuread_group" "readonly" {
  display_name     = "ReadOnly"
  security_enabled = true
}

# ── GROUP MEMBERSHIP ──
resource "azuread_group_member" "dev_member" {
  group_object_id  = azuread_group.developers.id
  member_object_id = azuread_user.dev_user.id
}

resource "azuread_group_member" "ops_member" {
  group_object_id  = azuread_group.operations.id
  member_object_id = azuread_user.ops_user.id
}

resource "azuread_group_member" "readonly_member" {
  group_object_id  = azuread_group.readonly.id
  member_object_id = azuread_user.readonly_user.id
}

# ── APP REGISTRATION ──
resource "azuread_application" "web_app" {
  display_name = "terraform-web-app"

  api {
    requested_access_token_version = 2
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "web_app_sp" {
  client_id = azuread_application.web_app.client_id
}

# ── RBAC ROLE ASSIGNMENTS ──
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "developers_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.developers.id
}

resource "azurerm_role_assignment" "operations_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.operations.id
}

resource "azurerm_role_assignment" "readonly_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.readonly.id
}