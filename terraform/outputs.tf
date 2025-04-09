output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset"
  value       = google_bigquery_dataset.dbt_dataset.dataset_id
}

output "dbt_service_account_email" {
  description = "The email of the DBT service account"
  value       = google_service_account.dbt_jobs_service_account.email
}

output "airflow_environment_name" {
  description = "The name of the Cloud Composer environment"
  value       = google_composer_environment.airflow_env.name
}

output "airflow_environment_id" {
  description = "The ID of the Cloud Composer environment"
  value       = google_composer_environment.airflow_env.id
} 