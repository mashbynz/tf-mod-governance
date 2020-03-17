variable "level0_NSG" {}
variable "level0_networks" {}

variable "log_analytics_object" {
  description = "(Required) Object describing the configuration of the Log Analytics workspace"
}

variable "log_analytics_suffix" {
  description = "(Optional) The suffix added to the Log Analytics workspace name to ensure it is globally unique"
  type        = string
}

variable "diagnostics_object" {
  description = "(Required) configuration object describing the Diagnostics configuration"
}

variable "networking_object" {
  description = "(Required) configuration object describing the networking configuration, as described in README"
}

# variable "enable_event_hub" {
#   description = "(Required) Set to true to create an event hub for Diagnostics Logging"
#   type = bool
# }
