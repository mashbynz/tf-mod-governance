locals {
  tags = {
    environment   = "Prod"
    "cost centre" = "12345"
  }
 
  checkifcreateconfig     = lookup(var.networking_object.netwatcher, "create", {}) != {} ? var.networking_object.netwatcher.create : false
  nsg                     = local.checkifcreateconfig == true ? var.level0_NSG : {} 

  # nsg   = var.level0_NSG
  vnets = var.level0_networks
}
