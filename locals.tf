locals {
  tags = {
    environment   = "Prod"
    "cost centre" = "12345"
  }

  nsg   = var.level0_NSG
  vnets = var.level0_networks
}
