# Random string generator for globally unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "random_string" "diagnostics_suffix" {
  length  = 8
  special = false
  upper   = false
}

## Log Analytics
# Workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  for_each = var.log_analytics_object.workspaces

  name                = "${each.value.name}${random_string.suffix.result}"
  location            = each.value.location
  resource_group_name = each.value.log_analytics_rg
  sku                 = "PerGB2018"
  tags                = lookup(each.value, "tags", null) == null ? local.tags : merge(local.tags, each.value.tags)
}

# Solutions
resource "azurerm_log_analytics_solution" "log_analytics_solutions" {
  for_each = var.log_analytics_object.solution_plan_map

  solution_name         = each.value.name
  location              = each.value.location
  resource_group_name   = each.value.log_analytics_rg
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics[each.value.workspace_key].id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics[each.value.workspace_key].name

  plan {
    product   = each.value.product
    publisher = each.value.publisher
  }

  depends_on = [
    azurerm_log_analytics_workspace.log_analytics
  ]
}

## Diagnostics Logs
# Storage Account
resource "azurerm_storage_account" "log" {
  for_each = var.diagnostics_object.storage_accounts

  name                      = "${each.value.name}${random_string.diagnostics_suffix.result}"
  resource_group_name       = each.value.resource_group_name
  location                  = each.value.location
  account_kind              = each.value.account_kind
  account_tier              = each.value.account_tier
  account_replication_type  = each.value.account_replication_type
  access_tier               = each.value.access_tier
  enable_https_traffic_only = each.value.enable_https_traffic_only
  tags                      = lookup(each.value, "tags", null) == null ? local.tags : merge(local.tags, each.value.tags)
}

# NSG Diagnostics
resource "azurerm_monitor_diagnostic_setting" "nsg_diag" {
  depends_on = [var.level0_NSG]

  for_each = var.level0_NSG

  name                       = var.diagnostics_object.nsg_diagnostics.name
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics[var.diagnostics_object.nsg_diagnostics.log_analytics_workspace_key].id
  log {

    category = "NetworkSecurityGroupRuleCounter"
    retention_policy {
      days    = var.diagnostics_object.nsg_diagnostics.opslogs_retention_period
      enabled = true

    }
  }
  log {

    category = "NetworkSecurityGroupEvent"
    retention_policy {
      days    = var.diagnostics_object.nsg_diagnostics.opslogs_retention_period
      enabled = true

    }
  }
}

# Event Hub Namespace - CHECK IF REQUIRED
# resource "azurerm_eventhub_namespace" "log" {
#   for_each = var.diagnostics_object.event_hubs

#   name                 = "${each.value.name}${random_string.diagnostics_suffix.result}"
#   location             = each.value.location
#   resource_group_name  = each.value.resource_group_name
#   sku                  = each.value.sku
#   capacity             = each.value.capacity
#   auto_inflate_enabled = each.value.auto_inflate_enabled
#   tags                 = lookup(each.value, "tags", null) == null ? local.tags : merge(local.tags, each.value.tags)
#   # kafka_enabled       = true
# }

## Traffic Analytics
# Network Watcher
resource "azurerm_network_watcher" "netwatcher" {
  for_each = var.networking_object.netwatcher.watchers

  name                = "${var.networking_object.netwatcher.name}${each.value.location}"
  location            = each.value.location
  resource_group_name = each.value.virtual_network_rg
  tags                = lookup(each.value, "tags", null) == null ? local.tags : merge(local.tags, each.value.tags)
}

### NOT SUPPORTED IN AU CENTRAL 1 OR 2 ###
# # NSG Flow Logs
# resource "azurerm_network_watcher_flow_log" "nsg_flow" {
#   for_each = var.level0_NSG

#   network_watcher_name = "${var.networking_object.netwatcher.name}${each.value.location}"
#   resource_group_name  = each.value.resource_group_name

#   network_security_group_id = each.value.id
#   storage_account_id        = azurerm_storage_account.log[var.networking_object.netwatcher.storage_account_key].id
#   enabled                   = lookup(var.networking_object.netwatcher, "flow_logs_settings", {}) != {} ? var.networking_object.netwatcher.flow_logs_settings.enabled : false

#   retention_policy {
#     enabled = lookup(var.networking_object.netwatcher, "flow_logs_settings", {}) != {} ? var.networking_object.netwatcher.flow_logs_settings.retention : false
#     days    = lookup(var.networking_object.netwatcher, "flow_logs_settings", {}) != {} ? var.networking_object.netwatcher.flow_logs_settings.period : 7
#   }

#   traffic_analytics {
#     enabled               = lookup(var.networking_object.netwatcher, "traffic_analytics_settings", {}) != {} ? var.networking_object.netwatcher.traffic_analytics_settings.enabled : false
#     workspace_id          = azurerm_log_analytics_workspace.log_analytics[var.networking_object.netwatcher.log_analytics_workspace_key].workspace_id
#     workspace_region      = azurerm_log_analytics_workspace.log_analytics[var.networking_object.netwatcher.log_analytics_workspace_key].location
#     workspace_resource_id = azurerm_log_analytics_workspace.log_analytics[var.networking_object.netwatcher.log_analytics_workspace_key].id
#   }

#   depends_on = [
#     azurerm_network_watcher.netwatcher
#   ]
# }
