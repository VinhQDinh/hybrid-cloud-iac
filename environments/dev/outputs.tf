output "resource_group_name" {
    description = "The name of the provisioned Hub Resource Group."
    value = azurerm_resource_group.hub.name
}

output "resourc_group_id" {
    description = "The Resource ID of the provisioned Hub Resource Group."
    value = azurerm_resource_group.hub.id
}

output "vnet_id" {
    description = "The Resource ID of the Hub Virtual Network."
    value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
    description = "The name of the Hub Virtual Network."
    value = azurerm_virtual_network.hub.name
}

output "gateway_subnet_id" {
    description = "The Resource ID of the dedicated GatewaySubnet (for VPN Gateway)."
    value = azurerm_subnet.gateway.id
}

output "shared_services_subnet_id" {
    descripion = "The Resource ID of the Shared Services subnet."
    value = azurerm_subnet.shared_services.id
}

output "private_endpoints_subnet_id" {
    description = "The Resource ID of the Private Endpoints subnet."
    value = azurerm_subnet.private_endpoints.id
}

output "hub_nsg_id" {
    description = "The Resource ID of the Hub Network Security Group."
    value = azurerm_network_security_group.hub.id
}