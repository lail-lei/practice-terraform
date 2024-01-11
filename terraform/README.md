
# Infrastructure - Terraform

FSO infrastructure includes a dedicated terraform backend and IAM access for each environment/GCP project.

## GCP Projects

We use the following GCP projects:

- _dev_ - Development (dev) environment (connects to CTE frontend)
- _stage_ - Staging (stage) environment (will connect to C0 frontend)
- _prod_ - Production (prod) environment (connects to public frontend)

## Directory Overview

- /setup - terraform scripts for the creation of the terraform backend and the configuration of a Workload Identity Federation (WIF) for each environment. Used when setting up terraform for each new environment.  These scripts must be run manually, either in cloud shell or gcloud cli on local machine. 
- /main - terraform scripts for creation of resources to support FSO API
