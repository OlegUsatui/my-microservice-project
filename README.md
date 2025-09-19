# Flexible Terraform RDS Module (Aurora ⚡ or Single Instance)

This project delivers a production-ready, reusable Terraform **`modules/rds`** that can provision either:
- **Amazon Aurora cluster** (PostgreSQL/MySQL compatible) when `use_aurora = true`, or
- **Single RDS instance** when `use_aurora = false`.

The module **always** creates:
- DB Subnet Group
- Security Group (ingress on the selected port)
- Parameter Group (engine-specific), supporting overrides via `parameter_overrides`

It’s wired into a minimal example stack that also bootstraps an S3 state backend and a small VPC with private subnets.

> Terraform ≥ 1.6, AWS provider ≥ 5.x

---

## Quick start

```bash
cd lesson-db-module
cp secrets.auto.tfvars.example secrets.auto.tfvars   # put a strong db_master_password
terraform init
terraform plan
terraform apply
```

> To switch to a remote state backend, first apply once (to create the S3 bucket + DynamoDB), then uncomment `backend.tf` and re-run `terraform init -migrate-state`.

---

## Example usage

Two examples are included in `main.tf`:

### Aurora PostgreSQL
```hcl
module "rds_aurora" {
  source          = "./modules/rds"
  name            = "lesson-aurora"
  use_aurora      = true
  engine          = "aurora-postgresql"
  engine_version  = "15.4"
  instance_class  = "db.r6g.large"
  db_name         = "appdb"
  master_username = "dbadmin"
  master_password = var.db_master_password
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]
  port            = 5432
  parameter_overrides = {
    max_connections = "200"
  }
}
```

### Single RDS instance (PostgreSQL)
```hcl
module "rds_instance" {
  source          = "./modules/rds"
  name            = "lesson-pg"
  use_aurora      = false
  engine          = "postgres"
  engine_version  = "15.6"
  instance_class  = "db.t4g.medium"
  db_name         = "appdb"
  master_username = "dbadmin"
  master_password = var.db_master_password
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]
  port            = 5432
}
```

---

## Module inputs (`modules/rds/variables.tf`)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | n/a | Name prefix for all RDS resources. |
| `use_aurora` | `bool` | `false` | Toggle between Aurora (true) and single RDS instance (false). |
| `engine` | `string` | `"postgres"` | DB engine: `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql`. |
| `engine_version` | `string` | `null` | Engine version for the selected engine. |
| `instance_class` | `string` | `"db.t4g.medium"` | DB instance class (or Aurora instance class). |
| `db_name` | `string` | `"appdb"` | Initial database name. |
| `master_username` | `string` | `"dbadmin"` | Master username. |
| `master_password` | `string` | n/a (sensitive) | Master password. Put this in `secrets.auto.tfvars`. |
| `port` | `number` | `5432` | DB port (3306 for MySQL). |
| `multi_az` | `bool` | `false` | Multi-AZ for single RDS instance. |
| `storage_gb` | `number` | `20` | Allocated storage for single RDS instance. |
| `storage_type` | `string` | `"gp3"` | Storage type for single RDS instance. |
| `deletion_protection` | `bool` | `false` | Prevent DB deletion. |
| `backup_retention_days` | `number` | `1` | Automated backups retention. |
| `vpc_id` | `string` | n/a | VPC ID where security group will be created. |
| `subnet_ids` | `list(string)` | n/a | Private subnet IDs for DB subnet group. |
| `allowed_cidr_blocks` | `list(string)` | `[]` | CIDRs allowed to connect to the DB SG. |
| `parameter_overrides` | `map(string)` | `{}` | Key/Value overrides merged into the parameter group. |

---

## Outputs

- `writer_endpoint` (Aurora)
- `reader_endpoint` (Aurora)
- `instance_endpoint` (single RDS)
- `security_group_id`
- `db_subnet_group_name`

---

## Change engine / class / version

Switch `engine` and `engine_version` to the desired ones:

- PostgreSQL single instance: `engine = "postgres"`, `port = 5432`
- MySQL single instance: `engine = "mysql"`, `port = 3306`
- Aurora PostgreSQL: `engine = "aurora-postgresql"`
- Aurora MySQL: `engine = "aurora-mysql"`

Change `instance_class` to a compatible class (e.g., `db.t4g.medium`, `db.r6g.large`).

---

## Notes

- RDS is placed in **private subnets**. Access it from inside the VPC (e.g., via bastion/EC2/EKS). Open `allowed_cidr_blocks` or attach additional SGs as needed.
- Parameter groups are created per-engine automatically; you can override values with `parameter_overrides`.
