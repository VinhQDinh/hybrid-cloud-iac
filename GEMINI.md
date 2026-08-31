# Antigravity Pair-Programming Guidelines & Environment Context

## Interaction Rules
1. **Do not modify or write project code directly.** The user types and edits project code manually.
2. **Present code snippets for one file at a time** for the user to write/type.
3. **Provide a detailed, line-by-line explanation** of all syntax, arguments, and command logic.

## Environment Records
- **Tenant ID:** `f06b19a9-e74b-4e95-a8cf-24a7f86c70d0`
- **Subscription ID:** `f4f16e55-1b3e-474f-98ab-74ae4c1f6453`
- **Primary Region:** `centralus`
- **Storage Account (Remote State):** `sttfstatehybrid20c19b`
- **Resource Group (Remote State):** `rg-terraform-state-mgmt`
- **Container (Remote State):** `tfstate-hybrid-enterprise`
- **State Key:** `hybrid-core.tfstate`

## Architecture & Implementation Status

### Phase 1: Azure Hub Network (Current Phase)
- [x] **Remote State Backend:** Configured AzureRM backend in `backend/backend.tf` with Azure AD authentication.
- [x] **Environment Variables:** Defined in `environments/dev/variables.tf` (Hub VNet, Gateway, Shared Services, Private Endpoints CIDRs, and Tags).
- [x] **Hub Network & Subnets (`environments/dev/main.tf`):**
  - Resource Group: `rg-hub-core-centralus`
  - Virtual Network: `vnet-hub-core-centralus` (`10.100.0.0/16`)
  - Subnets:
    - `GatewaySubnet` (`10.100.0.0/24`) — Dedicated for VPN Gateway.
    - `snet-shared-services-centralus` (`10.100.1.0/24`) — For jumpboxes and internal services.
    - `snet-private-endpoints-centralus` (`10.100.2.0/24`) — For Key Vault and Storage Private Links.
- [x] **Zero-Trust Network Security Group (`environments/dev/main.tf`):**
  - NSG: `nsg-hub-centralus`
  - Rules: `Allow-SSH-Internal` (Port 22 from `VirtualNetwork`), `Deny-All-Inbound-Internet` (Priority 4096).
  - Subnet Associations: Bound to `shared_services` and `private_endpoints` subnets.

### Next Session Priorities
1. **Define Variable Values:** Populate `environments/dev/terraform.tfvars`.
2. **Define Outputs:** Create `environments/dev/outputs.tf` for VNet ID, Subnet IDs, and NSG ID.
3. **Execution & Validation:** Initialize backend (`terraform init`) and test deployment via `terraform plan`.
4. **VPN Gateway & Key Vault:** Provision Azure Virtual Network Gateway and Key Vault for on-prem opnSense connectivity.
