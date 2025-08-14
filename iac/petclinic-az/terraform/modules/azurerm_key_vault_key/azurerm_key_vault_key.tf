locals {
  create_rsa_key = var.key_type == "RSA" || var.key_type == "RSA-HSM" ? true : false
  create_ec_key  = var.key_type == "EC" || var.key_type == "EC-HSM" ? true : false
}

resource "azurerm_key_vault_key" "this" {
  name            = var.key_name
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = local.create_rsa_key ? var.key_size : null
  key_opts        = var.key_opts
  not_before_date = coalesce(var.not_before_date, " ") != " " ? var.not_before_date : null
  curve           = local.create_ec_key ? var.curve : null
  expiration_date = var.expiration_date
  dynamic "rotation_policy" {
    for_each = var.expire_after != null ? [var.expire_after] : []
    content {
      expire_after         = var.expire_after
      notify_before_expiry = var.notify_before_expiry
      dynamic "automatic" {
        for_each = var.time_after_creation != null || var.notify_before_expiry != null ? [1] : []
        content {
          time_after_creation = var.time_after_creation
          time_before_expiry  = var.time_before_expiry
        }
      }
    }
  }
}






