# Enterprise Hybrid Cloud Architecture Guide
**Stack:** Proxmox VE · opnSense · Terraform · Kubernetes (K3s/Talos) · Azure Arc · Entra ID

---

## 1. High-Level Architecture Overview

+-----------------------------------------------------------------------------------+
|                               MICROSOFT ENTRA ID                                  |
|                        (SSO / RBAC / Managed Identities)                          |
+-----------------------------------------+-----------------------------------------+
                                          |
          +-------------------------------+-------------------------------+
          |                                                               |
          v                                                               v
+---------------------------------------+       +---------------------------------------+
|          AZURE PUBLIC CLOUD           |       |            ON-PREM HOMELAB            |
|                                       |       |                                       |
|  +---------------------------------+  |       |  +---------------------------------+  |
|  | Platform Landing Zone           |  |       |  | Proxmox Cluster (3 Nodes)       |  |
|  | (Terraform Managed)             |  |       |  |  - VM Templates (Ubuntu/Talos)  |  |
|  |  - Hub VNet, Key Vault, Storage |  |       |  |  - Multi-Node K8s Cluster      |  |
|  |  - Azure Virtual Network Gateway|  |       |  +----------------+----------------+  |
|  +----------------+----------------+  |       |                   |                   |
|                   |                   |       |  +----------------+----------------+  |
|                   |                   |       |  | opnSense Router                |  |
|                   |                   |       |  |  - Site-to-Site IPsec VPN      |  |
|                   |                   |       |  |  - VLAN Isolation / Local DNS  |  |
|                   |                   |       |  +----------------+----------------+  |
+-------------------|-------------------+       +-------------------|-------------------+
                    |                                               |
                    +======== IPsec S2S VPN (opnSense) =============+
                                            |
                                            v
                        +---------------------------------------+
                        |        AZURE ARC CONTROL PLANE        |
                        | - GitOps Policies (Flux v2)           |
                        | - Azure Monitor & Defender            |
                        | - Azure RBAC for Local K8s            |
                        +---------------------------------------+

---

## 2. Core Components & Resume Action Bullets

### Infrastructure as Code (IaC)
- **Implementation:** Terraform / OpenTofu provisioning both Azure cloud resources and Proxmox VMs (via bpg/proxmox or Telmate/proxmox provider).
- **Resume Bullet:** "Engineered multi-provider Terraform pipelines to orchestrate hybrid cloud infrastructure across Azure subscriptions and on-prem Proxmox clusters."

### Hybrid Networking
- **Implementation:** opnSense + Azure VNet Gateway running a Site-to-Site IPsec tunnel with static or BGP routing.
- **Resume Bullet:** "Architected secure Site-to-Site IPsec VPN between opnSense and Azure VNet, enforcing zero-trust network segmentation and private routing."

### Kubernetes Infrastructure
- **Implementation:** K3s or Talos Linux deployed across 3 Proxmox nodes, utilizing cert-manager, Ingress-Nginx, and local persistent storage.
- **Resume Bullet:** "Provisioned highly available multi-node Kubernetes clusters with declarative IaC, automated ingress TLS, and stateful storage provisioners."

### Hybrid Governance
- **Implementation:** Azure Arc-enabled Kubernetes attached to your Microsoft tenant.
- **Resume Bullet:** "Integrated on-prem K8s into Azure Arc control plane to enforce centralized Azure Governance, Microsoft Defender for Containers, and GitOps deployments."

### Identity & Security
- **Implementation:** Entra ID (Azure AD) for Kubernetes cluster authentication using OpenID Connect (OIDC) and Workload Identity.
- **Resume Bullet:** "Implemented Enterprise Single Sign-On (SSO) and RBAC for Kubernetes using Microsoft Entra ID and OIDC authentication protocols."

### CI/CD Pipeline
- **Implementation:** GitHub Actions with OIDC authentication to Azure (keyless authentication) for automated terraform plan/apply.
- **Resume Bullet:** "Designed zero-trust CI/CD pipelines using GitHub Actions with Azure OIDC federation to automate infrastructure lifecycle management."

---

## 3. Step-by-Step Execution Plan & Milestone Progress

### Phase 1: Azure Landing Zone via Terraform (In Progress)
- [x] **Azure Remote State:** Provisioned resource group (`rg-terraform-state-mgmt`), storage account (`sttfstatehybrid20c19b`), and container (`tfstate-hybrid-enterprise`) with blob versioning enabled.
- [x] **Backend & Providers:** Configured `backend/backend.tf` (AzureAD authentication) and `providers.tf` (AzureRM, Proxmox, Random).
- [ ] **Hub Network Module (`modules/azure_hub`):**
  - [x] Module Inputs & CIDR variables (`modules/azure_hub/variables.tf`)
  - [x] Virtual Network & Subnets (`modules/azure_hub/main.tf`)
  - [x] Zero-Trust Network Security Group (`modules/azure_hub/main.tf`)
  - [ ] Module Outputs (`modules/azure_hub/outputs.tf`)
- [ ] **Root Dev Environment (`environments/dev`):** Instantiate and validate `terraform plan`.
- [ ] **VPN Gateway & Secret Management:**
  - [ ] Azure Virtual Network Gateway (Route-based IPsec VPN).
  - [ ] Azure Key Vault for central secret management.
  - [ ] Log Analytics Workspace for unified diagnostics.

### Phase 2: Hybrid Networking (opnSense <-> Azure)
- [ ] Configure **IPsec Site-to-Site VPN tunnel** on opnSense targeting Azure Gateway Public IP.
- [ ] Establish private route tables between Proxmox subnets (`192.168.1.0/24`) and Azure Hub (`10.100.0.0/16`).

### Phase 3: Automated On-Premises K8s Cluster Build
- [ ] **Cloud-Init Template:** Build Ubuntu Server / Talos Linux template on Proxmox.
- [ ] **Proxmox Terraform Provider:** Automate VM provisioning across 3 Proxmox nodes.
- [ ] **Cluster Bootstrap:** Bootstrap highly available K8s cluster (K3s / Talos).

### Phase 4: Azure Arc Integration & GitOps
- [ ] **Arc Onboarding:** Connect local Kubernetes cluster to Azure Arc control plane (`az connectedk8s connect`).
- [ ] **Centralized Telemetry:** Stream container logs and metrics into Azure Log Analytics.
- [ ] **GitOps Deployment:** Reconcile workloads via Azure Arc Flux v2 extension.

### Phase 5: Entra ID Authentication & Zero Trust
- [ ] Register application in **Microsoft Entra ID**.
- [ ] Enforce Azure RBAC & OIDC authentication for `kubectl` cluster access.

---

## 4. High-Impact Enhancements ("X-Factors")

- **Secrets Management:** Deploy External Secrets Operator (ESO) in Kubernetes to fetch secrets dynamically from Azure Key Vault over the private VPN.
- **Cost Management & Governance:** Configure Azure Cost Management budgets and apply Azure Policy for Kubernetes to block non-compliant workloads (e.g., preventing privileged containers).