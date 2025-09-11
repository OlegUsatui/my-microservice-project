# Lesson 5 — Terraform AWS Infrastructure (S3+DynamoDB backend, VPC, ECR)

Цей проєкт розгортає інфраструктуру AWS за допомогою Terraform у директорії `lesson-5`:
- **S3** (з версіюванням) для зберігання Terraform state.
- **DynamoDB** для блокування state-файлу.
- **VPC** із 3 публічними та 3 приватними підмережами, **Internet Gateway**, **NAT Gateway**, таблиці маршрутів.
- **ECR** репозиторій з ввімкненим **скануванням образів** та політикою доступу.

> Регіон: `us-west-2`  
> S3 bucket: `usaty-oleg-terraform-state`  
> DynamoDB: `terraform-locks`  
> ECR: `lesson-5-ecr`

---

## Вимоги
- AWS акаунт та налаштований доступ (AWS CLI або змінні оточення `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION=us-west-2`).
- Terraform **v1.5+** (рекомендовано v1.6+).
- Доступ до регіону **us-west-2**.

## Структура проєкту
