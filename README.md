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

## 3. Step-by-Step Execution Plan

### Phase 1: Azure Landing Zone via Terraform
1. **Azure Remote State:** Create a dedicated Resource Group, Storage Account, and Blob Container for remote Terraform state storage with state locking enabled.
2. **Modular IaC:** Write Terraform modules to provision:
   - A Hub Virtual Network (VNet) in Azure.
   - An Azure Virtual Network Gateway (Route-based IPsec VPN).
   - An Azure Key Vault for central secret management.
   - A Log Analytics Workspace for unified logging.

### Phase 2: Hybrid Networking (opnSense <-> Azure)
1. Configure an **IPsec Site-to-Site VPN tunnel** on opnSense targeting the Azure Gateway Public IP.
2. Establish private route tables so Proxmox subnets communicate directly with Azure private endpoints over encrypted traffic without traversing the public internet.

### Phase 3: Automated On-Premises K8s Cluster Build
1. **Cloud-Init Template:** Create an automated Ubuntu Server or Talos Linux VM template on Proxmox using Cloud-Init.
2. **Proxmox Terraform Provider:** Use Terraform to automatically clone and provision 3 VMs (1 Control Plane, 2 Worker Nodes) across your 3-node Proxmox cluster.
3. **Cluster Bootstrap:** Bootstrap a Kubernetes cluster (K3s or Talos) using Ansible or talosctl.

### Phase 4: Azure Arc Integration & GitOps
1. **Arc Onboarding:** Execute `az connectedk8s connect` to register your local Proxmox Kubernetes cluster into your Microsoft Azure tenant.
2. **Centralized Telemetry:** Attach Azure Monitor Container Insights to stream pod logs and metrics directly into your Log Analytics workspace.
3. **GitOps Deployment:** Use Azure Arc's Flux v2 extension pointing to a GitHub repository to automatically reconcile container workloads to your cluster.

### Phase 5: Entra ID Authentication
1. Register an Application in **Microsoft Entra ID**.
2. Configure Kubernetes OIDC flags (or Azure Arc RBAC) to mandate Microsoft credential authentication for kubectl access.

---

## 4. High-Impact Enhancements ("X-Factors")

- **Secrets Management:** Deploy External Secrets Operator (ESO) in Kubernetes to fetch secrets dynamically from Azure Key Vault over the private VPN.
- **Cost Management & Governance:** Configure Azure Cost Management budgets and apply Azure Policy for Kubernetes to block non-compliant workloads (e.g., preventing privileged containers).