resource "azurerm_resource_group" "rg" {
  tags     = merge(var.tags, {})
  name     = "rg1"
  location = var.location
}

resource "azurerm_linux_function_app" "linux_function_app" {
  tags                       = merge(var.tags, {})
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id
  resource_group_name        = azurerm_resource_group.rg.name
  name                       = "onboarding"
  location                   = var.location

  site_config {
    always_on = true
  }
}

resource "azurerm_service_plan" "service_plan" {
  tags                = merge(var.tags, {})
  sku_name            = "P1v3"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  name                = "onboarding"
  location            = var.location
}

resource "azurerm_storage_account" "storage_account" {
  tags                     = merge(var.tags, {})
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "onboarding"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_subnet" "snet" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet1"

  address_prefixes = [
    "10.0.1.0/24",
  ]
}

resource "azurerm_virtual_network" "vnet" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.rg.name
  name                = "vnet1"
  location            = var.location

  address_space = [
    "10.0.0.1/16",
  ]
}

resource "azurerm_private_endpoint" "pe" {
  tags                = merge(var.tags, {})
  subnet_id           = azurerm_subnet.snet.id
  resource_group_name = azurerm_resource_group.rg.name
  name                = "onboarding"
  location            = var.location

  private_service_connection {
    private_connection_resource_id = azurerm_linux_function_app.linux_function_app.id
    name                           = "onboarding"
    is_manual_connection           = false
    subresource_names = [
      "sites",
    ]
  }
}

