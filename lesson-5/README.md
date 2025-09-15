**# AWS Infrastructure with Terraform — Remote State (S3 + DynamoDB), VPC, ECR

## Overview

Проєкт розгортає базову інфраструктуру AWS за допомогою Terraform:

* **Remote state** у S3 з **локами** в DynamoDB (версіонування, шифрування, заборона публічного доступу).
* **VPC** з 3 публічними та 3 приватними підмережами, **Internet Gateway**, **1 NAT Gateway** (економний варіант), таблиці маршрутів.
* **ECR** репозиторій зі **scan-on-push** та мінімальною ресурсною політикою для акаунта.

Підійде як стартова мережа для контейнерних застосунків і мікросервісів.

---

## Prerequisites

* Terraform ≥ 1.5
* AWS CLI v2
* Налаштовані креденшали (профіль напр. `lesson5`)
* Регіон за замовчуванням: `us-west-2` (можна змінити, але узгодити скрізь)

---

## Project layout

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
---

## Quick start

### 1) Налаштування

У `main.tf` задай:

* **унікальне** ім’я S3 бакета для стейту (лише `a-z`, цифри, `-`)
* `table_name = "terraform-locks"`
* у `provider "aws"` — твій регіон/профіль (наприклад, `us-west-2`, `lesson5`)

### 2) Bootstrapping remote state (одноразово)

> Спершу створюємо S3/DynamoDB **без** підключеного бекенду, потім мігруємо стейт у S3.

1. **Вимкни бекенд**: перейменуй `backend.tf` → `backend.tf.disabled` (або закоментуй вміст).
2. Створи лише бекенд-ресурси **локально**:

   ```bash
   terraform init
   terraform apply -target=module.s3_backend -auto-approve -lock=false
   ```
3. **Увімкни бекенд** та **мігруй стейт** у S3:

   ```bash
   mv backend.tf.disabled backend.tf
   terraform init -migrate-state
   ```

### 3) Деплой інфраструктури

```bash
terraform plan
terraform apply
```

### 4) Outputs (приклади)

* `vpc_id`
* `public_subnet_ids`, `private_subnet_ids`
* `ecr_repository_url`
* `s3_backend_bucket`, `s3_backend_dynamodb_table`

---

## ECR — швидкий старт

```bash
# Login до ECR (підстав регіон/профіль за потреби)
aws ecr get-login-password --region us-west-2 --profile lesson5 \
| docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d'/' -f1)

# Збірка та пуш
export REPO=$(terraform output -raw ecr_repository_url)
docker build -t $REPO:latest .
docker push $REPO:latest
```

---

## Teardown (обережно з бекендом)

```bash
# Безпечний варіант: спочатку повернутись на локальний стейт
mv backend.tf backend.tf.disabled
terraform init -reconfigure
terraform destroy
```

> **NAT Gateway** має погодинну та тарифікацію за трафік. У конфігурації використано **1 NAT** для економії.

---

## Notes

* Імена S3 бакетів мають бути **глобально унікальні**.
* Регіон у `provider` та у `backend.tf` має збігатися з реальним розміщенням бакета.
* Не зберігай ключі доступу в репозиторії; `.gitignore` має виключати стейт-файли.
  **