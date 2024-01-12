# Set up IAM access

These scripts are used to create (or update) IAM access for a GCP project/environment. The new GCP project will need to be accessible by two GitHub repositories (via workflows). For each of these repos, a Workload Identity Federation (WIF) pool will be created and granted the roles each repository needs. The repos are: 

- infrastructure (in which the code you're reading lives, to deploy infrastructure to the GCP project)
- API (to deploy the cloud run api)

[setup and running instructions] (../../README.md)

### Created GitHub Service Accounts

 - gh-oidc-infra (used by workflows in current repo)
 - gh-oidc-api-cicd (used by workflows in API repo)