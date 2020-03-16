locals {
  tags = {
    environment   = "Prod"
    "cost centre" = "12345"
  }

  # checkifconfigpresent = lookup(var.nw_config, "create", {}) != {} ? true : false
  # checkifcreateconfig  = lookup(var.nw_config, "create", {}) != {} ? var.nw_config.create : false
  # nsg                  = local.checkifconfigpresent == true ? var.nsg : {}
}
