## Terraform - Main infrastructure

These scripts create project resources and service accounts used by project resources. Note, scripts for the creation of service accounts used by external environments (GitHub repos) are found in [setup/terraform_access](../setup/terraform_access/README.md) 

### Deployment

These scripts should be run only through GitHub workflows (i.e., should NOT be run via `gcloud cli` or cloud shell).
For description of standard deployment workflow used in this project, read [here](../../.github/workflows/README.md)
 
### Components 
- [FSO Cloud Run API](./modules/fso_api/README.md)
- [Firestore export cloud function](./modules/firestore_export/README.md)

### Data
#### Database
Application data is stored in Firebase (running in Datastore mode).
There's two collections: 
- _Orders_ - order and fulfillment-related data, including product ids, order confirmation codes, and shipping address
- _WebAppUser_ - basic profile and contact info of users of the web application, for marketing purposes

#### Dataset 
Application data is exported to a BigQuery dataset called: `firestore_app_data`