## Terraform - Setup 

These scripts set up terraform backends and terraform IAM access for a new GCP project/environment. The scripts must
be run manually, either in cloud shell, or through `gcloud cli` on a local machine. 


### Directory overview 

- terraform_backend: Scripts used to 1., create a Google Cloud Storage (GCS) bucket for terraform backend files
and then 2., to actually store the terraform backend file in the newly-created GCS bucket. 

- terraform_access: Scripts used to create (or update) IAM access for a GCP project/environment. The new GCP project will need to be accessible by two GitHub repositories (via workflows). For each of these repos, a Workload Identity Federation (WIF) pool will be created and granted the roles each repository needs. The repos are: 
    - infrastructure (in which the code you're reading lives, to deploy infrastructure to the GCP project)
    - API (to deploy the cloud run api)

### Created GitHub Service Accounts

 - gh-oidc-infra (used by workflows in current repo)
 - gh-oidc-api-cicd (used by workflows in API repo)


### Manual Setup Instructions For New GCP projects

Begin by creating the backend bucket that will store the terraform state. Each environment will have its dedicated backend bucket.

1. Log into the the project console and activate the cloud shell, OR from your local machine: `gcloud auth login && gcloud config set project <PROJECT_ID>`
2. Change the working directory: `cd ./terraform/setup/terraform_backend`
3. Temporarily remove backend block from main.tf (commented, lines 11-17)
4. Run: `terraform init`
5. Run: `terraform validate`
6. Create terraform plan: `terraform plan -var-file="envs/<NEW_ENVIRONMENT>/vars.tfvars" -out="envs/<NEW_ENVIRONMENT>/plan.tfplan"`
8. Deploy the planned resources: `terraform apply envs/<NEW_ENVIRONMENT>/plan.tfplan`
9. Create output backend file to be consumed later: `terraform output > envs/<NEW_ENVIRONMENT>/backend.tfbackend`
10. In main.tf, add back the codeblock previously removed in step 3.
11. Reconfigure terraform to use the backend storage bucket we just created: `terraform init -backend-config=envs/<NEW_ENVIRONMENT>/backend.tfbackend -reconfigure`. When asked "Do you want to copy existing state to the new backend?", answer `yes`

Now that we have the backend storage configured, let's create the IAM access for terraform to authenticate from GitHub actions:

12. Change working directory: `cd ../terraform_access`
13. Reconfigure terraform to use the new backend prefix: `terraform init -backend-config=../terraform_backend/envs/<NEW_ENVIRONMENT>/backend.tfbackend -reconfigure`
14. Run: `terraform validate`
15. Create terraform plan: `terraform plan -var-file="envs/<NEW_ENVIRONMENT>/vars.tfvars" -out="envs/<NEW_ENVIRONMENT>/plan.tfplan"`
16. Deploy the planned resources: `terraform apply envs/<NEW_ENVIRONMENT>/plan.tfplan` 


After these steps are complete, all changes to project infrastructure must be made via GitHub workflows. 
To change or update GitHub Service account roles/permissions, make necessary changes to the `wif_sa_roles_`
arrays in `/terraform_access/main.tf`, and run steps 12-16. 