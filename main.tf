# Random string generator for globally unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
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
resource "azurerm_log_analytics_solution" "networking_la" {
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

## Diagnostics
# Traffic Analytics
# resource "azurerm_network_watcher" "netwatcher" {
#   count = local.checkifcreateconfig && local.checkifconfigpresent ? 1 : 0

#   name                = var.nw_config.name
#   location            = var.location
#   resource_group_name = var.rg
#   tags                = var.tags
# }

# resource "azurerm_network_watcher_flow_log" "nw_flow" {

#   for_each = local.nsg

#   # if we havent created the azurerm_network_watcher.netwatcher
#   # then we take the value given (optional)
#   network_watcher_name = local.checkifcreateconfig ? azurerm_network_watcher.netwatcher[0].name : var.netwatcher.name
#   resource_group_name  = local.checkifcreateconfig ? var.rg : var.netwatcher.rg

#   network_security_group_id = each.value.id
#   storage_account_id        = var.diagnostics_map.diags_sa
#   enabled                   = lookup(var.nw_config, "flow_logs_settings", {}) != {} ? var.nw_config.flow_logs_settings.enabled : false

#   retention_policy {
#     enabled = lookup(var.nw_config, "flow_logs_settings", {}) != {} ? var.nw_config.flow_logs_settings.retention : false
#     days    = lookup(var.nw_config, "flow_logs_settings", {}) != {} ? var.nw_config.flow_logs_settings.period : 7
#   }

#   traffic_analytics {
#     enabled               = lookup(var.nw_config, "traffic_analytics_settings", {}) != {} ? var.nw_config.traffic_analytics_settings.enabled : false
#     workspace_id          = var.log_analytics_workspace.object.workspace_id
#     workspace_region      = var.log_analytics_workspace.object.location
#     workspace_resource_id = var.log_analytics_workspace.object.id
#   }
# }
