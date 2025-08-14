data "azurerm_resource_group" "this" {
  depends_on = [var.resource_group_name]
  name       = var.resource_group_name
}

resource "azurerm_role_definition" "this" {
  name        = var.name
  scope       = data.azurerm_resource_group.this.id
  description = var.description
  dynamic "permissions" {
    for_each = length(coalesce(var.actions, [])) > 0 || length(coalesce(var.data_actions, [])) > 0 || length(coalesce(var.not_actions, [])) > 0 || length(coalesce(var.not_data_actions, [])) > 0 ? [1] : []
    content {
      actions          = var.actions
      not_actions      = var.not_actions
      data_actions     = var.data_actions
      not_data_actions = var.not_data_actions
    }
  }
  assignable_scopes = length(coalesce(var.assignable_scopes, [])) > 0 ? var.assignable_scopes : [data.azurerm_resource_group.this.id]
}

resource "azurerm_role_assignment" "this" {
  count                = length(coalesce(var.actions, [])) > 0 || length(coalesce(var.data_actions, [])) > 0 || length(coalesce(var.not_actions, [])) > 0 || length(coalesce(var.not_data_actions, [])) > 0 ? 1 : 0
  principal_id         = var.principal_id
  role_definition_name = azurerm_role_definition.this.name
  scope                = var.scope == "" ? data.azurerm_resource_group.this.id : var.scope
}



