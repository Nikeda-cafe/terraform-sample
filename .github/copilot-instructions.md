# Copilot Instructions for Terraform Project

## Project Overview

This is a **Terraform monorepo** for AWS infrastructure with service-oriented architecture. The project manages multiple applications (Next.js, Express, Laravel) with shared infrastructure (RDS, Bastion, VPC Endpoints). Each service and the shared infrastructure have their own root modules organized by environment (dev/prod).

**Key repositories/paths:**
- `/shared/` - Shared infrastructure (RDS MySQL, EC2 Bastion, VPC Endpoints)
- `/nextjs-app/` - Next.js application ECS infrastructure
- `/express-app/` - Express application ECS infrastructure
- `/laravel-app/` - Laravel application ECS infrastructure (configuration exists)
- `/docs/` - Architecture and design documentation

## Project Structure

```
terraform/
├── shared/
│   ├── modules/
│   │   ├── rds/             # MySQL RDS instance module
│   │   ├── bastion/         # EC2 Bastion host module
│   │   └── vpc-endpoints/   # VPC Endpoints for ECR/CloudWatch
│   └── environment/
│       ├── dev/             # Dev environment deployment
│       └── prod/            # Prod environment deployment
├── {nextjs|express|laravel}-app/
│   ├── modules/
│   │   └── ecs/             # ECS cluster, service, ALB
│   └── environment/
│       ├── dev/
│       └── prod/
└── docs/
    ├── overview.md          # Architecture overview
    └── /shared/modules/
        ├── DESIGN.md        # Architecture and network design
        └── SPECIFICATION.md # Implementation specifications
```

## Deployment Order (Critical)

VPC Endpoints must be deployed before ECS services can pull images from ECR:

1. **shared** (VPC Endpoints, RDS, Bastion)
2. **nextjs-app**
3. **express-app**
4. **laravel-app** (if needed)

## Terraform Workflow

### Basic Commands

All Terraform commands are executed from the environment-specific directory (`{service}/environment/{dev|prod}/`).

```bash
# From service/environment/dev directory:
terraform init          # Initialize workspace (required after cloning)
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Remove infrastructure (use with caution)
```

### Example: Deploy shared infrastructure to dev

```bash
cd shared/environment/dev
terraform init
terraform plan
terraform apply
```

### To validate changes without applying

```bash
cd {service}/environment/{dev|prod}
terraform plan -out=tfplan
# Review the plan file
terraform apply tfplan
```

## Backend Configuration

- **Type:** S3 remote backend
- **Bucket:** `sample-terraform-state-bucket-na`
- **State keys:** `{service}/{environment}/terraform.tfstate`
  - Example: `shared/dev/terraform.tfstate`, `nextjs-app/prod/terraform.tfstate`
- **Region:** ap-northeast-1 (Tokyo)

State files are **isolated per service and environment** to allow independent deployments.

## Configuration Management

### Terraform Variables

Each environment uses `terraform.tfvars` for configuration:

```bash
shared/environment/dev/terraform.tfvars
```

**Common variables:**
- `environment` - "dev" or "prod"
- `prefix` - Resource name prefix (e.g., "dev-", "prod-")
- `region` - AWS region (ap-northeast-1)
- `tags` - Common tags applied to all resources

**Service-specific variables:**
- **shared:** `db_name`, `db_master_username`, `db_master_password`, `allocated_storage`, `bastion_instance_type`
- **ECS apps:** Instance types, desired task counts, container image URIs, port mappings

Sensitive values (passwords, secrets) are excluded from git via `.gitignore` (*.tfvars).

### Working with modules

Modules are located in `modules/` subdirectories and referenced in root module `main.tf`:

```hcl
module "rds" {
  source = "../../modules/rds"
  environment = var.environment
  # ... pass variables to module
}
```

**Common modules:**
- `rds` - MySQL database instance with security groups and subnet groups
- `bastion` - EC2 instance for secure DB access via Session Manager
- `vpc-endpoints` - VPC endpoints for ECR and CloudWatch Logs
- `ecs` - ECS cluster, service, ALB (shared between app modules)

## AWS Resources and Networking

### Existing AWS Infrastructure

The Terraform code references existing resources by tag/name filters:

- **VPC:** `udemy-aws-container-vpc` (CIDR: 10.0.0.0/16)
- **Public Subnets:** Tagged with `udemy-aws-container-subnet-public*`
- **Private Subnets:** Tagged with `udemy-aws-container-subnet-private*`
- **ECR Repositories:** Referenced by name in ECS task definitions

Resources are looked up using `data` sources (e.g., `data.aws_vpc`, `data.aws_subnets`) rather than hardcoded IDs.

### Network Security

- **RDS:** Accessible only from Bastion security group (port 3306)
- **Bastion:** Access via AWS Session Manager (IAM, no SSH keys required)
- **ECS:** ALB handles inbound traffic; tasks communicate with RDS through Bastion
- **VPC Endpoints:** Allow private communication with ECR and CloudWatch without internet gateway

## Development Practices

### Pull Request Reviews

- **Language:** All pull request reviews, review comments, and review summaries must be written in Japanese.

### Before modifying infrastructure

1. Read the relevant documentation:
   - `docs/overview.md` - High-level architecture
   - `shared/modules/DESIGN.md` - Network and security design
   - `shared/modules/SPECIFICATION.md` - Module implementation details

2. Run `terraform plan` and review changes carefully:
   ```bash
   cd {service}/environment/{env}
   terraform plan
   ```

3. Understand resource dependencies before applying:
   - `shared` must be deployed first
   - App modules depend on shared infrastructure

### Code organization conventions

- **File structure:** Each module has files for related resources (`security_group.tf`, `db_instance.tf`, etc.)
- **Variable naming:** Use `snake_case`; sensitive vars annotated with `sensitive = true`
- **Resource naming:** Prefix with `var.prefix` for environment distinction (e.g., `"${var.prefix}rds-sg"`)
- **Data sources:** Use tag-based lookups instead of hardcoded resource IDs
- **Outputs:** Each module exports key resource IDs/ARNs needed by other modules

### Resource synchronization

The `ecs` module is **duplicated** in both `nextjs-app` and `express-app`. Changes to one must be reflected in the other manually.

## Checkov Security Scanning (Optional)

The AWS Documentation + Terraform MCP servers are configured (see `.cursor/mcp.json`). Checkov can be run manually to scan for security issues:

```bash
checkov --framework terraform --directory ./
```

## State Migration Notes

If migrating from legacy `environment/{dev|prod}` structure to the new service-separated structure:

1. Use `terraform state mv` or `terraform state pull/push` to move resources
2. `vpc_endpoints` resources go to `shared`
3. `ecs` resources go to respective app modules
4. Delete old `.terraform/` directories after migration (they'll be regenerated with `init`)

## Useful Tips

- **Validate syntax** without AWS credentials: `terraform validate`
- **Format code:** `terraform fmt -recursive` (from repo root)
- **Inspect current state:** `terraform state list` and `terraform state show <resource>`
- **Debug output:** Add `TF_LOG=DEBUG` environment variable before running commands
- **Dry-run with lock:** Use `terraform plan -out=tfplan` to save the plan and `terraform apply tfplan` for exactly what was planned

## Troubleshooting

### Backend lock

If Terraform is stuck due to a lock file:
```bash
terraform force-unlock <LOCK_ID>
```

### Drift detection

To check if real AWS resources diverged from state:
```bash
terraform plan
```

If significant drift occurs, review the changes carefully before applying.

### Missing state file

Ensure S3 backend bucket exists and AWS credentials are configured:
```bash
aws s3 ls s3://sample-terraform-state-bucket-na/
```

## MCP Servers

The following MCP servers are configured in `.cursor/mcp.json`:
- **awslabs.aws-documentation-mcp-server** - AWS documentation search
- **awslabs.terraform-mcp-server** - Terraform provider documentation and validation
