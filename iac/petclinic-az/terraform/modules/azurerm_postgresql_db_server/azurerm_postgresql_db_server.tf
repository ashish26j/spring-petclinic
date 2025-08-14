resource "azurerm_postgresql_server" "this" {
  name                = var.postgresql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = var.auto_grow_enabled

  public_network_access_enabled    = var.public_network_access_enabled
  ssl_enforcement_enabled          = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.ssl_minimal_tls_version_enforced

  tags = var.tags

  dynamic "threat_detection_policy" {
    for_each = var.enable_threat_detection ? [1] : []
    content {
      enabled         = true
      email_addresses = var.email_addresses
    }
  }

}

resource "azurerm_postgresql_database" "example" {
  name                = var.postgresql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  charset             = var.charset
  collation           = var.collation

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_virtual_network_rule" "this" {
  count                                = length(var.subnet_ids)
  name                                 = "postgresql-vnet-rule-${count.index}"
  resource_group_name                  = var.resource_group_name
  server_name                          = azurerm_postgresql_server.this.name
  subnet_id                            = var.subnet_ids[count.index]
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_postgresql_configuration" "config" {
  for_each            = var.postgresql_configuration != null ? var.postgresql_configuration : {}
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  value               = each.value
}

resource "azurerm_postgresql_active_directory_administrator" "this" {
  count               = var.enable_active_directory_administrator ? 1 : 0
  server_name         = azurerm_postgresql_server.this.name
  resource_group_name = var.resource_group_name
  login               = var.ad_admin_login_name
  object_id           = var.ad_admin_object_id
  tenant_id           = var.ad_admin_tenant_id
}
