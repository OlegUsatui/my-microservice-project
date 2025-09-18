# lesson-7 — Terraform on AWS (S3 backend, DynamoDB locks, VPC, ECR, EKS, Helm)

## Prerequisites

* Terraform ≥ 1.6
* AWS credentials available in your shell (via `aws configure` or env vars)
* `kubectl` and `helm` installed locally
* Docker installed (for building and pushing images)
* Region: **us-west-2**
* Globally-unique S3 bucket for state: **my-tfstate-3575857895-lesson-5** (DynamoDB table: **terraform-locks**)

---

## Files

* `backend.tf` — S3 backend configuration (remote state)
* `main.tf` — providers + modules wiring (VPC, ECR, EKS via official module)
* `outputs.tf` — consolidated outputs (ECR URL, kubeconfig helper)
* `terraform.tfvars` — variable values (region, VPC, subnets, `ecr_name`, etc.)
* `modules/s3-backend/` — S3 (versioned) + DynamoDB table for state locks
* `modules/vpc/` — VPC with **3 public + 3 private** subnets, IGW, **NAT per AZ**, per‑AZ route tables
* `modules/ecr/` — ECR repository (scan‑on‑push, mutable tags)
* `charts/django-app/` — Helm chart (Deployment, Service, ConfigMap, HPA)

> Note: EKS is created via `terraform-aws-modules/eks/aws` directly in `main.tf` (no local `modules/eks`).

---

## ⚠️ Backend bootstrapping (first run)

Create the state backend once using the helper module, then switch to remote state.

```bash
cd modules/s3-backend
terraform init
terraform apply -auto-approve \
  -var "region=us-west-2" \
  -var "bucket_name=my-tfstate-3575857895-lesson-5" \
  -var "dynamodb_table_name=terraform-locks"
cd ../../lesson-7

terraform init -reconfigure \
  -backend-config="bucket=my-tfstate-3575857895-lesson-5" \
  -backend-config="key=lesson-7/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=terraform-locks"
```

---

## Create all infrastructure

```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -auto-approve -var-file="terraform.tfvars"
```

---

## Connect to EKS cluster

```bash
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region us-west-2
kubectl get nodes
```

---

## ECR usage

**Authenticate Docker to ECR**

```bash
aws ecr get-login-password --region us-west-2 \
| docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d'/' -f1)
```

**Build & push an image**

```bash
export REPO=$(terraform output -raw ecr_repository_url)
export TAG=v1

docker build -t $REPO:$TAG .
docker push $REPO:$TAG
```

---

## Deploy Django app with Helm

**Install metrics-server** (required for HPA)

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={"--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"}
```

**Deploy the application**

```bash
helm upgrade --install django-app ./charts/django-app -n default \
  --set image.repository="$(terraform output -raw ecr_repository_url)" \
  --set image.tag="v1"
```

**Verify**

```bash
kubectl get pods,svc,hpa -n default
```

---

## (Optional) Ingress + TLS (NGINX Ingress Controller + cert-manager)

**NGINX Ingress Controller**

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace
```

**cert-manager**

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace
```

**ClusterIssuer (Let’s Encrypt)**

```bash
kubectl apply -f clusterissuer.yaml
```

---

## Destroy

```bash
helm uninstall django-app -n default || true
terraform destroy -var-file="terraform.tfvars"
```

---

### Notes

* **ConfigMap:** put non‑secret envs in `charts/django-app/values.yaml` → `env`; mounted via `envFrom` in the Deployment.
* **HPA:** defaults to 2..6 replicas, 70% CPU (see `templates/hpa.yaml` / `.Values.autoscaling`).
* **Service:** type `LoadBalancer`; for L7 routing / TLS consider Ingress.
