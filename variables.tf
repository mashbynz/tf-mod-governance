variable "log_analytics_object" {
  description = "(Required) Object describing the configuration of the Log Analytics workspace"
}

variable "log_analytics_suffix" {
  description = "(Optional) The suffix added to the Log Analytics workspace name to ensure it is globally unique"
  type        = string
}
