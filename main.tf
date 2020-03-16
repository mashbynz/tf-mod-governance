resource "random_string" "suffix" {
  length = 8
  special = false
}


resource "azurerm_log_analytics_workspace" "log_analytics" {
  for_each = var.log_analytics_object

#   name                = "${each.value.name}${var.log_analytics_suffix}"
name                = "${each.value.name}${random_string.suffix.result}"
  location            = each.value.location
  resource_group_name = each.value.log_analytics_rg
  sku                 = "PerGB2018"
  tags                = lookup(each.value, "tags", null) == null ? local.tags : merge(local.tags, each.value.tags)
}

# resource "azurerm_log_analytics_solution" "la_solution" {
#   count                 = length(local.solution_list)
#   solution_name         = element(local.solution_list, count.index)
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
#   workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

#   // tags = var.tags
#   // Tags not implemented in TF for azurerm_log_analytics_solution

#   plan {
#     product   = var.solution_plan_map[element(local.solution_list, count.index)].product
#     publisher = var.solution_plan_map[element(local.solution_list, count.index)].publisher
#   }
# }
