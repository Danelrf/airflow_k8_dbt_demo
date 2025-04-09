# Enable required APIs
resource "google_project_service" "composer_api" {
  provider = google-beta
  project = var.project_id
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  // This parameter prevents automatic disabling
  // of the API when the resource is destroyed.
  // We recommend to disable the API only after all environments are deleted.
  disable_on_destroy = false
  // this flag is introduced in 5.39.0 version of Terraform. If set to true it will
  //prevent you from disabling composer_api through Terraform if any environment was
  //there in the last 30 days
  check_if_service_has_usage_on_destroy = true  # Only for google-beta
}

# Create a service account for DBT
resource "google_service_account" "dbt_jobs_service_account" {
  account_id   = "dbt-jobs-user"
  display_name = "DBT Service Account"
  description  = "Service account for DBT operations"
  project      = var.project_id 
}


resource "google_project_iam_member" "dbt_jobs_service_account" {
  project = var.project_id
  member = format("serviceAccount:%s", google_service_account.dbt_jobs_service_account.email)
  role = "roles/composer.worker"
}

resource "google_service_account_iam_member" "dbt_jobs_service_account" {
  provider = google-beta
  service_account_id = google_service_account.dbt_jobs_service_account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-667538242109@cloudcomposer-accounts.iam.gserviceaccount.com"
}

# Add BigQuery permissions to the service account
resource "google_project_iam_member" "dbt_bigquery_user" {
  project = var.project_id
  member = format("serviceAccount:%s", google_service_account.dbt_jobs_service_account.email)
  role = "roles/bigquery.user"
}

resource "google_project_iam_member" "dbt_bigquery_data_editor" {
  project = var.project_id
  member = format("serviceAccount:%s", google_service_account.dbt_jobs_service_account.email)
  role = "roles/bigquery.dataEditor"
}

# Create a Cloud Composer environment
resource "google_composer_environment" "airflow_env" {
  name   = "airflow-k8-demo-${var.environment}"
  project = var.project_id
  region = var.region
  config {
    node_config {
      service_account = google_service_account.dbt_jobs_service_account.email
    }
    
    software_config {
      image_version = "composer-2.12.0-airflow-2.10.2"
      env_variables = {
        AIRFLOW_VAR_DBT_PROJECT_DIR = "/home/airflow/gcs/dags/dbt"
      }
    }
  }
} 

# Create a BigQuery dataset
resource "google_bigquery_dataset" "dbt_dataset" {
  dataset_id    = "dbt_k8_demo"
  friendly_name = "DBT K8 Demo Dataset"
  description   = "Dataset for DBT transformations"
  location      = var.region
  project       = var.project_id 
}
