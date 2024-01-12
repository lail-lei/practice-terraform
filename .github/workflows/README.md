## Plan and Deploy Workflows

### Branches

There are two long-living branches:
- dev
- main 

Both require PRs to push, and approvals to merge PRs.

### Environments 

There is a dedicated GitHub environment for each GCP project/environment:

- `dev`  - connects to dev project id, integrated CTE environment
- `stage` - connects to stage project id, to be integrated with C0 environment  
- `prod` - connects to prod project id, to integrated with live production site

Prod includes an environment deployment protection rule. 

### Potential PR workflow

At some point, we may create a PR workflow that runs `terraform plan` on
creation of PR to `dev`.

### Main Deploy Workflow 

Any push to `dev` or `main` will trigger main workflow.

#### Pushes to Dev

Pushes from the dev branch will:
1. create a plan for the dev project
2. deploy the planned resources to the dev project


#### Pushes to Main

To help avoid resource drift between stage and prod environments, any push to `main`
will trigger jobs for both environments. 

Pushes to `main` will
1. create a plan for the stage project
2. deploy the planned resources to the stage project

Since the prod environment includes an environment deployment protection rule, the
workflow will pause and request reviews from other developers on the project. This pause
gives developers time to ensure that no unexpected changes occurred in the stage enviroment.

Once approval is granted, the workflow:

1. creates a plan for the prod project
2. deploy the planned resources to the prod project



