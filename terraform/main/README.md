# Main Infrastructure

Terraform scripts for the creation of project resources and related service accounts.

## Components 

- [api] (../modules/fso_api/README.md)
- [Firestore export cloud function] (../modules/fso_api/README.md)

## Data

## Database
Application data is stored in Firebase running in datastore mode.
There's two collections: 
- Orders (order and fulfillment-related data, including product ids, order confirmation codes, and shipping address)
- WebUser (basic profile and contact info of users of the web application)

## Dataset 
Application data is exported to a BigQuery dataset called: `firestore_app_data`.

