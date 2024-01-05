# Setup 

Terraform scripts for the creation of the terraform backend and the configuration of a Workload Identity Federation (WIF) for each environment. Used when setting up terraform for each new environment.  These scripts must be run manually, either in cloud shell or gcloud cli on local machine. 

## Manual Setup Instructions For New Project-id's

To setup terraform for each environment, the backend GCS bucket and service account need to be created on each GCP project account (dev/stage/prod). The following steps use the dev account as example:

1. Log into the the project console and activate the cloud shell (top right left icon) OR from your local machine: `gcloud auth login && gcloud config set project ${project-name}-dev`
2. Confirm terraform is installed: `terraform --version`
3. Clone this repo: `git clone [repo]`
4. Change working directory: `cd ./terraform/setup/terraform_backend`
5. Temporarily remove backend block from main.tf (likely lines 8-10)
6. Initiate terraform: `terraform init`
7. Terraform plan: `terraform plan -var-file="dev.tfvars" -out="dev.tfplan"`
8. Terraform apply: `terraform apply dev.tfplan`
9. Terraform output: `terraform output > dev.tfbackend`
10. Now that the backend storage is created, moving forward we need to store the state into the backend bucket that was just created. Add the backend block (removed in step 5) back into main.tf 
11. Reconfigure terraform to use the backend storage `terraform init -backend-config=dev.tfbackend -reconfigure`. When asked "Do you want to copy existing state to the new backend?", answer `yes`
12. Now that we have the backend storage configured, lets create the IAM access for terraform to authenticate from GitHub actions. Change working directory: `cd ../terraform_access`
13. Reconfigure terraform to use the new backend prefix (storage subfolder set in main.tf) `terraform init -backend-config=../terraform_backend/dev.tfbackend -reconfigure`
14. Terraform plan: `terraform plan -var-file="dev.tfvars" -out="dev.tfplan"`
15. Terraform apply: `terraform apply dev.tfplan`