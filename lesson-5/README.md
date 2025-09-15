# lesson-5 — Terraform on AWS (S3 backend, DynamoDB locks, VPC, ECR)

## ✅ Вимоги
- Terraform ≥ 1.5, AWS CLI
- AWS креденшали (профіль `lesson5`)
- Регіон за замовчуванням: `eu-central-1`

## 📁 Файли
## Структура проєкту

- `lesson-5/`
    - `main.tf` — головний файл для підключення модулів
    - `backend.tf` — налаштування бекенду для стейтів (S3 + DynamoDB)
    - `outputs.tf` — загальне виведення ресурсів
    - `modules/` — каталог з модулями
        - `s3-backend/` — модуль для S3 та DynamoDB
            - `s3.tf` — створення S3-бакета
            - `dynamodb.tf` — створення DynamoDB
            - `variables.tf` — змінні для S3/DynamoDB
            - `outputs.tf` — виведення інформації про S3 та DynamoDB
        - `vpc/` — модуль для VPC
            - `vpc.tf` — створення VPC, підмереж, Internet Gateway
            - `routes.tf` — налаштування маршрутизації
            - `variables.tf` — змінні для VPC
            - `outputs.tf` — виведення інформації про VPC
        - `ecr/` — модуль для ECR
            - `ecr.tf` — створення ECR-репозиторію
            - `variables.tf` — змінні для ECR
            - `outputs.tf` — виведення URL репозиторію ECR
    - `README.md` — документація проєкту

## ⚙️ Bootstrapping бекенду (перший запуск)
1. У `main.tf` вистави:
    - `bucket_name = <унікальний S3 бакет>`
    - `table_name  = "terraform-locks"`
2. Тимчасово вимкни бекенд → перейменуй `backend.tf` ➝ `backend.tf.disabled`
3. Створи лише бекенд-ресурси **локально**:
   ```bash
   terraform init
   terraform apply -target=module.s3_backend -auto-approve -lock=false
Увімкни бекенд і мігруй стейт:


mv backend.tf.disabled backend.tf
terraform init -migrate-state

🚀 Створення інфраструктури
terraform plan
terraform apply

🧹 Безпечне видалення
mv backend.tf backend.tf.disabled
terraform init -reconfigure
terraform destroy

🐳 ECR (швидкий старт)
aws ecr get-login-password --region eu-central-1 --profile lesson5 \
| docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d'/' -f1)

export REPO=$(terraform output -raw ecr_repository_url)
docker build -t $REPO:latest . && docker push $REPO:latest
