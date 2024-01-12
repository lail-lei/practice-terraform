## FSO Cloud Run API

This module creates resources necessary for the FSO API.

### Resources 

- Cloud Run Revision
    - Application code uses attached service account to:
        - read/write Firestore data
        - write logs (using Winston)

- Artifact Registry repo to store Docker Images

### Source Code

GitHub Repository API source code:


### Code Deployment 

API GitHub workflow use the `gh-oidc-api-cicd` service account to:
- upload a new Docker Image to the `europe-west1-docker.pkg.dev/GCP_PROJECT_ID>/fso-api/fso-api` image path in Artifact Registry 
- re-deploy the Cloud Run Revision

Note: when setting up FSO infrastructure for a new GCP project, we must first use a dummy image path for 
`api_cloud_run_container_image_path`. Example: `us-docker.pkg.dev/cloudrun/container/hello`

Once the Cloud Run resource is created, we:
1. Build and deploy a new image from the API GitHub Repo
2. In `envs/<ENVIRONMENT>/vars.tfvars`, update `api_cloud_run_container_image_path` to point to the image deployed previous step


