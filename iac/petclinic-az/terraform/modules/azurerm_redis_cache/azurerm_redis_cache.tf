resource "azurerm_redis_cache" "this" {
  name                          = var.cache_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  non_ssl_port_enabled          = var.non_ssl_port_enabled
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  dynamic "patch_schedule" {
    for_each = var.patch_schedule
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }
}

resource "azurerm_redis_firewall_rule" "this" {
  name                = var.firewall_rule_name
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = azurerm_redis_cache.this.resource_group_name
  start_ip            = var.start_ip
  end_ip              = var.end_ip
}



