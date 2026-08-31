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

# 4. Shared Services Subnet (Jumpboxes, DNS, Domain Controller)
resource "azurerm_subnet" "shared_services" {
    name = "snet-shared-services-centralus"
    resource_group_name = azurerm_resource_group.hub.name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = var.shared_services_subnet_cidr
}

# 5. Private Endpoints Subnet (Key Vault, Storage Private Links)
resource "azurerm_subnet" "private_endpoints" {
    name = "snet-private-endpoints-centralus"
    resource_group_name = azurerm_resource_group.hub.name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = var.private_endpoints_subnet_cidr
}

#6. Hub Network Security Group (Baseline Zero-Trust Rules)
resource "azurerm_network_security_group" "hub" {
    name = "nsg-hub-centralus"
    location = azurerm_resource_group.hub.location
    resource_group_name = azurerm_resource_group.hub.name
    tags = var.tags

    security_rule {
        name                       = "Allow-SSH-From-SharedServices"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "Deny-All-Inbound"
        priority = 4096
        direction = "Inbound"
        access = "Deny"
        protocol = "*"
        source_port_range = "*"
        destination_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

# 7. Subnet-to-NSG Associations
resource "azurerm_subnet_network_security_group_association" "shared_services" {
    subnet_id = azurerm_subnet.shared.services.id
    network_security_group_id = azurerm_network_security_group.hub_nsg.id
}

resource "azurerm_subnet_network_security_group" "private_endpoints" {
    subnet_id = azurerm_subnet.private.endpoints.id
    network_security_group_id = azurerm_network_security_group.hub.nsg.id
}