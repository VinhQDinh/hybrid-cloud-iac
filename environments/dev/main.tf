# 1. Hub Resource Group
resource "azurerm_resource_group" "hub" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

# 2. Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
    name = var.vnet_name
    location = azurerm_resource_group.hub.location
    resource_group_name = azurerm_resource_group.hub.name
    address_space = var.vnet_address_space
    tags = var.tags 
}

# 3. Dedicated Gateway Subnet (Required for VPN Gateway)
resource "azurerm_subnet" "gateway" {
    name = "GatewaySubnet"
    resource_group_name = azurerm_resource_group.hub.name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = var.gateway_subnet_cidr
}