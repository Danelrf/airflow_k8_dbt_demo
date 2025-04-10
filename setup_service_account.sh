#!/bin/bash

# Set variables
PROJECT_ID="danel-dbt-project"
SERVICE_ACCOUNT_NAME="dbt-jobs-user"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
USER_EMAIL="danel.ramirez.flores@gmail.com"

echo "Setting up DBT service account and permissions..."

# Set the project
echo "Setting project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Create the service account
echo "Creating service account ${SERVICE_ACCOUNT_NAME}..."
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
    --display-name="DBT Service Account" \
    --description="Service account for DBT operations" \
    --project=${PROJECT_ID}

# Grant BigQuery permissions
echo "Granting BigQuery permissions to service account..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/bigquery.jobUser"

# Grant service account token creator role to user
echo "Granting service account token creator role to user..."
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_EMAIL} \
    --member="serviceAccount:service-30271547565@cloudcomposer-accounts.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

echo "Setup complete!"
echo "Service account email: ${SERVICE_ACCOUNT_EMAIL}"
echo "Please update your dbt/profiles.yml with the service account email above" 

# gsutil ls -L -b gs://$(gcloud composer environments describe airflow-k8-demo-dev --location europe-west2 --format="get(config.dagGcsPrefix)")