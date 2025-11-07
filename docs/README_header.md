# Modules Factory Terraform Module

Modules Factory module which manages configuration and life-cycle
of your Terraform modules.

## Permissions

### GitHub Permissions

To manage the GitHub resources, provide a token from an account or a GitHub App with
appropriate permissions. It should have:

* Read access to `metadata`
* Read and write access to `administration`, `code`, and `secrets`

### HCP Terraform Permissions

To manage resources, provide a user token from an account with appropriate
permissions. This user should have the `Manage modules` permission.
Alternatively, you can use a token from a team instead of a user token.

## Authentication

### GitHub Authentication

The GitHub provider requires a GitHub token or GitHub App installation in order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the `token` argument in the provider configuration. Use an
input variable for the token.
* Set the `GITHUB_TOKEN` environment variable. The provider can read the `GITHUB_TOKEN` environment variable and the token stored there
to authenticate.

There are several ways to provide the required GitHub App installation:

* Set the `app_auth` argument in the provider configuration. You can set the app_auth argument with the id, installation_id and pem_file
in the provider configuration. The owner parameter is also required in this situation.
* Set the `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID` and `GITHUB_APP_PEM_FILE` environment variables. The provider can read the GITHUB_APP_ID,
GITHUB_APP_INSTALLATION_ID and GITHUB_APP_PEM_FILE environment variables to authenticate.

> Because strings with new lines is not support:</br>
> use "\\\n" within the `pem_file` argument to replace new line</br>
> use "\n" within the `GITHUB_APP_PEM_FILE` environment variables to replace new line</br>

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
* Set the `TFE_TOKEN` environment variable. The provider can read the TFE_TOKEN environment variable and the token stored there
to authenticate.

## Features

* Create and manage repositories within your GitHub organization or personal account for your Terraform modules.
  * Configure branch protection.
  * Configure teams access.
* Publish module inside the private registry of your HCP Terraform organization.
  * Enable no-code feature when specified.

## Usage example

```hcl
module "repository" {
  source  = "app.terraform.io/<organization>/modulesfactory/tfe"
  version = "0.0.0"
  module_name     = "test"
  module_provider = "tfe"
}
```
