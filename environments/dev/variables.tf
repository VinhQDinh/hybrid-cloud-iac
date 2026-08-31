variable "resource_group_name" {                                                                                                                           
      description = "The name of the Resource Group where the Hub network resources will reside."                                                              
      type        = string                                                                                                                                     
    }                                                                                                                                                          
                                                                                                                                                               
    variable "location" {                                                                                                                                      
      description = "The Azure Region for the Hub network (e.g., centralus)."                                                                                  
      type        = string                                                                                                                                     
      default     = "centralus"                                                                                                                                
    }                                                                                                                                                          
                                                                                                                                                               
    variable "vnet_name" {                                                                                                                                     
      description = "The name of the Hub Virtual Network."                                                                                                     
      type        = string                                                                                                                                     
      default     = "vnet-hub-core-centralus"                                                                                                                  
    } 

    variable "vnet_address_space" {
        description = "The overall CIDR address space for the Hub Virtual Network."
        type = list(string)
        default = ["10.100.0.0/16"]
    }

    variable "gateway_subnet_cidr" {
         description = "The dedicated subnet CIDR for Azure Virtual Network Gateway (must be name GatewaySubnet)."
         type = list(string)
         default = ["10.100.0.0/24"]
    }

    variable "shared_services_subnet_cidr" {
        description = "Subner CIDR for core shared services, jumpboxes, or domain conrtollers."
        type = list(string)
        default = ["10.100.1.0/24"]
    }

    variable "private_endpoints_subnet_cidr" {
        description = "Subnet CIDR dedicated for Azure Private Endpoints (Key Vault, Storage, etc.)."
        type = list(string)
        default = ["10.100.2.0/24"]
    }

    variable "tags" {
        description = "Resource tags applied to all provisioned Hub networking components."
        type = map(string)
        default = {
            Environment = "Core-Hub"
            Project = "Hybrid=Cloud-Enterprise"
            ManagedBy = "Terraform"
        }
    }