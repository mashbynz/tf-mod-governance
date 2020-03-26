output "log_analytics_obj" {
  description = "Output a list of Log Analytics Workspace objects"
    depends_on  = [azurerm_log_analytics_workspace.log_analytics]

  value      = azurerm_log_analytics_workspace.log_analytics
}

output "log_analytics_solution_obj" {
  description = "Output a list of Log Analytics Solutions"
    depends_on  = [azurerm_log_analytics_solution.log_analytics_solutions]

  value      = azurerm_log_analytics_solution.log_analytics_solutions
}

output "storage_account_obj" {
  description = "Output a list of Storage Accounts"
    depends_on  = [azurerm_storage_account.log]

  value      = azurerm_storage_account.log
}
