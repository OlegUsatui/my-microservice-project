module "s3_backend" {
  source = "./modules/s3-backend"
  bucket_name = var.backend_bucket_name
  dynamodb_table = var.backend_lock_table
  project_name = var.project_name
}
