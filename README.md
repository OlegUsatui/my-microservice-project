# Final Project – AWS + Terraform + EKS/RDS/ECR + Jenkins + Argo CD + Prometheus/Grafana

---

## 0) Prerequisites

* Terraform ≥ 1.6, AWS CLI, kubectl, helm, docker, git
* AWS credentials in shell (e.g., `aws configure`)
* Region: **eu-north-1** (Stockholm)
* Names:

    * **S3 state bucket**: `oleh-usatyi-tfstate-eun1-20250919`
    * **DynamoDB table**: `tf-locks-final-devops`
    * **ECR repo**: `final-devops-django` 

**Cost warning:** EKS, RDS, NAT GW cost money. Destroy when done.

---

## 1) Repo Structure (as required)

```
Project/
├── main.tf
├── backend.tf
├── outputs.tf
├── providers.tf (optional – or inside modules)
├── variables.tf
├── terraform.tfvars
├── modules/
│  ├── s3-backend/ (s3.tf, dynamodb.tf, variables.tf, outputs.tf)
│  ├── vpc/        (vpc.tf, routes.tf, variables.tf, outputs.tf)
│  ├── ecr/        (ecr.tf, variables.tf, outputs.tf)
│  ├── eks/        (eks.tf, aws_ebs_csi_driver.tf, variables.tf, outputs.tf)
│  ├── rds/        (rds.tf, aurora.tf, shared.tf, variables.tf, outputs.tf)
│  ├── jenkins/    (jenkins.tf, values.yaml, variables.tf, providers.tf, outputs.tf)
│  └── argo_cd/    (argo.tf, values.yaml, variables.tf, providers.tf, outputs.tf, charts/...)
├── charts/
│  └── django-app/ (Chart.yaml, values.yaml, templates/...)
└── Django/ (Dockerfile, Jenkinsfile, docker-compose.yaml, app/)
```

---

## 2) Variables (`terraform.tfvars`)

```hcl
region          = "eu-north-1"
name            = "final-devops"

# Remote state
tf_state_bucket = "oleh-usatyi-tfstate-eun1-20250919"
tf_lock_table   = "tf-locks-final-devops"

# Networking
vpc_cidr        = "10.0.0.0/16"
azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# Container registry
ecr_name        = "final-devops-django"

# Database
db_username     = "app"
db_password     = "MyStrongPass123!" 
```

---

## 3) Backend (`backend.tf`)

```hcl
terraform {
  backend "s3" {
    bucket         = "oleh-usatyi-tfstate-eun1-20250919"
    key            = "final-project/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "tf-locks-final-devops"
    encrypt        = true
  }
}
```

> Enable this **after** the S3/DynamoDB are created the first time (see bootstrap below).

---

## 4) Bootstrap & Provision (exact order)

### A) First-time bootstrap (create S3 + DynamoDB for state)

```bash
cd Project
# init without active backend (if needed, comment out backend.tf temporarily)
terraform init
# create only state infra
terraform apply -target=module.s3_backend
# now enable backend.tf or keep it, then migrate state
terraform init -migrate-state
```

### B) Create all infrastructure

```bash
terraform apply
```

### C) EKS kubeconfig

```bash
aws eks update-kubeconfig --region eu-north-1 --name $(terraform output -raw cluster_name)
```

---

## 5) Build & Push Image to ECR

```bash
# Login
aws ecr get-login-password --region eu-north-1 | \
  docker login --username AWS --password-stdin 598357935226.dkr.ecr.eu-north-1.amazonaws.com

# Build & tag
export ECR=598357935226.dkr.ecr.eu-north-1.amazonaws.com/final-devops-django
(cd Django && docker build -t $ECR:latest .)

docker push $ECR:latest
---

## 6) Install Monitoring (Prometheus + Grafana)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns monitoring || true
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword=admin123
```

---

## 7) Verification Commands (required in task)

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

### Port-forwards

```bash
# Jenkins UI
kubectl -n jenkins  port-forward svc/jenkins                          8080:8080
# Argo CD UI
kubectl -n argocd   port-forward svc/argo-cd-argocd-server            8081:443
# Grafana UI
kubectl -n monitoring port-forward svc/grafana                        3000:80
```

Grafana login: `admin` / `admin123` (as set above). Argo CD default admin pwd (if not overridden):

```bash
kubectl -n argocd get secret argo-cd-argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

---

## 8) Argo CD Applications (connect your repo)

Fill `modules/argo_cd/charts/values.yaml` like:

```yaml
applications:
  - name: django-app
    repoURL: https://github.com/OlegUsatyi/my-microservice-project.git
    path: charts/django-app
    targetRevision: main
    namespace: default
    valueFiles: []
repositories: []
```

Then deploy the app definitions:

```bash
helm upgrade --install apps ./modules/argo_cd/charts -n argocd
```

---

## 9) Scoring Checklist (map to rubric)

* [ ] **Architecture (20):** VPC with public/private subnets, IGW + NAT, EKS nodes in private, RDS subnet group
* [ ] **Security (20):** SGs limited to VPC/EKS, IAM scoped for CI, encrypted S3 state, DynamoDB locks
* [ ] **CI/CD (30):** Jenkins builds & pushes to ECR; Argo CD syncs django Helm app
* [ ] **Monitoring & HPA (20):** kube-prometheus-stack installed; HPA enabled for app
* [ ] **Docs (10):** This README + notes updated with your repo URLs

---

## 10) Cleanup (avoid costs)

```bash
terraform destroy
```

---

## 11) Useful Ops

```bash
# Check AZs
aws ec2 describe-availability-zones --region eu-north-1 --query 'AvailabilityZones[].ZoneName'

# Force Argo sync (if CLI is inside the server pod)
kubectl -n argocd exec deploy/argo-cd-argocd-server -- argocd app sync django-app --grpc-web || true

# Describe HPA
kubectl get hpa -A
```

---
