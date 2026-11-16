# Azure Entra ID & Identity Management

## Project Overview

This project demonstrates Identity and Access Management (IAM) on Microsoft Azure using Entra ID. It covers user lifecycle management, group-based access control, app registrations, service principals, and RBAC — implemented first through the Azure Portal and then automated using Terraform.

---

## Skills Demonstrated

- Microsoft Entra ID user and group management
- Role-Based Access Control (RBAC) with least-privilege principles
- App registrations and service principal creation
- Multi-Factor Authentication (MFA) enforcement
- Infrastructure as Code using Terraform (azurerm + azuread providers)
- Remote Terraform state management with Azure Blob Storage
- Service principal authentication for automated deployments

---

## Architecture

```
Azure Subscription
└── Resource Group: rg-entra-iam-project
    ├── Entra ID Users
    │   ├── dev-user       → Developers group → Contributor (resource group)
    │   ├── ops-user       → Operations group → Reader (resource group)
    │   └── readonly-user  → ReadOnly group   → Reader (resource group)
    ├── Entra ID Groups
    │   ├── Developers     (security-enabled)
    │   ├── Operations     (security-enabled)
    │   └── ReadOnly       (security-enabled)
    ├── App Registration: terraform-web-app
    │   └── Service Principal (Microsoft Graph: User.Read scope)
    └── RBAC Role Assignments (group-based)
```

---

## Phase 1 — Azure Portal (Manual Setup)

### What was done

All resources were first created manually through the Azure Portal to understand the concepts before automating them.

**Step 1: Create Users**
- Created three Entra ID users: `dev-user`, `ops-user`, `readonly-user`
- Set temporary passwords with forced password change on first login

**Step 2: Create Security Groups**
- Created three security-enabled groups: `Developers`, `Operations`, `ReadOnly`
- Assigned each user to their respective group

**Step 3: Create App Registration**
- Registered application `terraform-web-app` in Entra ID
- Added Microsoft Graph `User.Read` delegated permission
- Created a service principal for the application

**Step 4: Create Service Principal with Contributor Role**
- Created a dedicated service principal `terraform-sp` for Terraform automation
- Assigned `Contributor` role at subscription scope to allow resource management

**Step 5: Assign RBAC Roles**
- `Developers` group → `Contributor` on the resource group
- `Operations` group → `Reader` on the resource group
- `ReadOnly` group → `Reader` on the resource group

**Additional: MFA Enforcement**
- Enabled Multi-Factor Authentication (MFA) for all three users as a security hardening step

### Screenshots
*(See `/screenshots` folder in this repository)*

---

## Phase 2 — Terraform (Infrastructure as Code)

### What was done

All resources from Phase 1 were re-created using Terraform to demonstrate automation and repeatability.

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- Azure CLI or a configured Service Principal
- Azure Storage Account for remote state

### File Structure

```
terraform/
├── providers.tf       # Provider configuration + remote state backend
├── variables.tf       # Input variable declarations
├── terraform.tfvars   # Variable values (excluded from version control)
├── main.tf            # All resources: users, groups, app registration, RBAC
├── outputs.tf         # Output values
└── .gitignore         # Excludes tfvars, state files, .terraform/
```

### Remote State Configuration

Terraform state is stored remotely in Azure Blob Storage:

| Setting | Value |
|---|---|
| Resource Group | `rg-terraform-state` |
| Storage Account | `tfstatebagi402` |
| Container | `tfstate` |
| State Key | `entra-iam.tfstate` |

### Service Principal Permissions

The `terraform-sp` service principal requires the following to run this configuration:

| Permission | Type | Purpose |
|---|---|---|
| `Directory.Read.All` | Graph API (Application) | Read tenant domain |
| `User.ReadWrite.All` | Graph API (Application) | Create/manage users |
| `Group.ReadWrite.All` | Graph API (Application) | Create/manage groups |
| `Application.ReadWrite.All` | Graph API (Application) | Create app registrations |
| `Owner` | RBAC on resource group | Assign roles to groups |

> **Note:** Admin consent must be granted for all Graph API permissions.

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Bagi0402/EntraID_and_RBAC.git
   cd terraform
   ```

2. Create `terraform.tfvars` (not committed — see `.gitignore`):
   ```hcl
   subscription_id = "your-subscription-id"
   tenant_id       = "your-tenant-id"
   client_id       = "your-service-principal-client-id"
   client_secret   = "your-service-principal-client-secret"
   tenant_domain   = "yourtenant.onmicrosoft.com"
   ```

3. Initialise Terraform:
   ```bash
   terraform init
   ```

4. Preview changes:
   ```bash
   terraform plan
   ```

5. Apply:
   ```bash
   terraform apply
   ```

### Resources Created

| Resource | Type | Description |
|---|---|---|
| `rg-entra-iam-project` | Resource Group | Container for all project resources |
| `dev-user` | Entra ID User | Developer persona |
| `ops-user` | Entra ID User | Operations persona |
| `readonly-user` | Entra ID User | Read-only persona |
| `Developers` | Security Group | Contributor access |
| `Operations` | Security Group | Reader access |
| `ReadOnly` | Security Group | Reader access |
| `terraform-web-app` | App Registration | Demonstrates app identity |
| RBAC assignments (×3) | Role Assignment | Group-based least-privilege access |

### Key Learnings from Terraform

- Service principals need explicit Graph API permissions with admin consent to manage Entra ID resources via Terraform
- `Directory.Read.All` is required even for reading the tenant domain
- Role assignments require `Owner` (not `Contributor`) on the scope, as `Contributor` cannot modify IAM
- Remote state must be configured before `terraform init` — the storage container must exist first
- `terraform.tfvars` must never be committed; use `.gitignore` to exclude it

---

## Security Notes

- All secrets and credentials are stored in `terraform.tfvars` which is excluded from version control via `.gitignore`
- Passwords for demo users are temporary and require change on first login
- The service principal follows least-privilege — permissions are scoped to what Terraform needs only
- MFA was enabled for all users as an additional security layer (Phase 1)

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Microsoft Azure | Cloud platform |
| Microsoft Entra ID | Identity provider |
| Terraform | Infrastructure as Code |
| Azure Blob Storage | Remote Terraform state |
| GitHub | Version control |

---

## Repository Structure

```
.
├── README.md
├── console-screenshots/        # Phase 1 portal screenshots
└── terraform/
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    └── .gitignore
```
