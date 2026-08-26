<!-- BEGIN_TF_DOCS -->
# Modules Factory Terraform Module

Modules Factory module which manages configuration and life-cycle
of your Terraform modules using Azure DevOps as the VCS provider.

## Permissions

### Azure DevOps Permissions

To manage Azure DevOps resources, provide a Personal Access Token (PAT) from an account
with appropriate permissions on the target project. The PAT should have:

* **Code** — Read & Write (to create and manage Git repositories)
* **Project and Team** — Read (to look up the project UUID)

### HCP Terraform Permissions

To manage resources, provide a user token from an account with appropriate
permissions. This user should have the `Manage modules` permission.
Alternatively, you can use a token from a team instead of a user token.

## Authentication

### Azure DevOps Authentication

The Azure DevOps provider requires a Personal Access Token (PAT) to manage resources.

There are several ways to provide the required token:

* Set the `personal_access_token` argument via the `azuredevops_personal_access_token`
  input variable in the module call.
* Set the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable. The provider reads this
  variable automatically, so the input variable can be omitted when it is set.

The organization service URL is constructed automatically from the
`azuredevops_service_url` and `azuredevops_organization` input variables:

```
https://dev.azure.com/<azuredevops_organization>
```

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `tfe_token` input variable in the module call.
* Set the `TFE_TOKEN` environment variable. The provider reads the `TFE_TOKEN`
  environment variable and the token stored there to authenticate.

## Features

* Create and manage Git repositories within your Azure DevOps project for your Terraform modules.
  * Configure branch policies (minimum reviewers, comment resolution, merge strategies, auto-reviewers).
* Publish the module inside the private registry of your HCP Terraform organization.
  * Enable the no-code feature when specified.
* Automatically provision `tfe_test_variable` resources so that HCP Terraform module tests
  have access to the required Azure DevOps credentials.

## Usage example

```hcl
module "modulesfactory" {
  source  = "app.terraform.io/<organization>/modulesfactory/tfe"
  version = "0.0.0"

  # Identity of the module to publish
  module_name     = "storage-account"
  module_provider = "azurerm"

  # Azure DevOps VCS connection
  azuredevops_organization          = "my-ado-org"
  azuredevops_project_name          = "My ADO Project"
  azuredevops_personal_access_token = var.ado_pat   # or use AZDO_PERSONAL_ACCESS_TOKEN env var

  # HCP Terraform
  organization       = "my-hcp-org"
  oauth_client_name  = "AzureDevOps"
  tfe_token          = var.tfe_token                 # or use TFE_TOKEN env var
}
```

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.16)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Modules

The following modules are called by this module:

### <a name="module_repository"></a> [repository](#module\_repository)

Source: `./modules/azuredevops_repository`

Creates and configures the Azure DevOps Git repository and its branch policies.

## Required Inputs

The following input variables are required:

### <a name="input_module_name"></a> [module\_name](#input\_module\_name)

Description: (Required) The name of the Terraform module.

Type: `string`

### <a name="input_module_provider"></a> [module\_provider](#input\_module\_provider)

Description: (Required) The main provider the module uses (e.g., `azurerm`, `aws`).

Type: `string`

### <a name="input_azuredevops_organization"></a> [azuredevops\_organization](#input\_azuredevops\_organization)

Description: (Required) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL).

Type: `string`

### <a name="input_azuredevops_personal_access_token"></a> [azuredevops\_personal\_access\_token](#input\_azuredevops\_personal\_access\_token)

Description: (Required) The Azure DevOps Personal Access Token used to authenticate. Can also be set via the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable.

Type: `string` (sensitive)

### <a name="input_azuredevops_project_name"></a> [azuredevops\_project\_name](#input\_azuredevops\_project\_name)

Description: (Required) The name of the Azure DevOps project in which the repository will be created.

Type: `string`

### <a name="input_organization"></a> [organization](#input\_organization)

Description: (Required) HCP Terraform organization name.

Type: `string`

### <a name="input_tfe_token"></a> [tfe\_token](#input\_tfe\_token)

Description: (Required) HCP Terraform API token used by child workspaces to publish modules into the private registry.

Type: `string` (sensitive)

### <a name="input_oauth_client_name"></a> [oauth\_client\_name](#input\_oauth\_client\_name)

Description: (Required) Name of the OAuth client connecting HCP Terraform to Azure DevOps.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_azuredevops_service_url"></a> [azuredevops\_service\_url](#input\_azuredevops\_service\_url)

Description: (Optional) The base URL of the Azure DevOps service. Defaults to `https://dev.azure.com`.

Type: `string`

Default: `"https://dev.azure.com"`

### <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch)

Description: (Optional) The short name of the default branch (without the `refs/heads/` prefix). Defaults to `main`.

Type: `string`

Default: `"main"`

### <a name="input_disabled"></a> [disabled](#input\_disabled)

Description: (Optional) Whether the repository is disabled. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_initialization"></a> [initialization](#input\_initialization)

Description: (Optional) Repository initialization configuration.
  - `init_type` : How to initialize the repository. Valid values: `Clean`, `Uninitialized`, `Import`.
  - `source_url`: URL of the source Git repository when `init_type` is `Import`.

Type:

```hcl
object({
  init_type  = string
  source_url = optional(string, null)
})
```

Default: `{ init_type = "Clean" }`

### <a name="input_no_code_module"></a> [no\_code\_module](#input\_no\_code\_module)

Description: (Optional) Whether this module will be a no-code module.

Type: `bool`

Default: `false`

### <a name="input_branch_policies"></a> [branch\_policies](#input\_branch\_policies)

Description: (Optional) List of branch policy configurations to apply to the repository. Each entry supports: `branch_ref`, `match_type` (`Exact`/`Prefix`/`DefaultBranch`), `enabled`, `blocking`, `require_comment_resolution`, `min_reviewers`, `merge_types`, and `auto_reviewers`.

Type:

```hcl
list(object({
  branch_ref                 = string
  match_type                 = optional(string, "Exact")
  enabled                    = optional(bool, true)
  blocking                   = optional(bool, true)
  require_comment_resolution = optional(bool, false)
  min_reviewers = optional(object({
    reviewer_count                         = number
    submitter_can_vote                     = optional(bool, false)
    last_pusher_cannot_approve             = optional(bool, true)
    allow_completion_with_rejects_or_waits = optional(bool, false)
    on_push_reset_approved_votes           = optional(bool, true)
    on_push_reset_all_votes                = optional(bool, false)
  }), null)
  merge_types = optional(object({
    allow_squash                  = optional(bool, true)
    allow_rebase_and_fast_forward = optional(bool, false)
    allow_basic_no_fast_forward   = optional(bool, true)
    allow_rebase_with_merge       = optional(bool, false)
  }), null)
  auto_reviewers = optional(object({
    reviewer_ids       = list(string)
    submitter_can_vote = optional(bool, false)
    message            = optional(string, null)
    path_filters       = optional(list(string), [])
  }), null)
}))
```

Default: Branch policy on `refs/heads/main` requiring 1 reviewer, comment resolution, and squash/basic merge types.

## Resources

The following resources are used by this module:

- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource, via `module.repository`)
- [azuredevops_branch_policy_min_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_min_reviewers) (resource, via `module.repository`)
- [azuredevops_branch_policy_comment_resolution.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_comment_resolution) (resource, via `module.repository`)
- [azuredevops_branch_policy_merge_types.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_merge_types) (resource, via `module.repository`)
- [azuredevops_branch_policy_auto_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_auto_reviewers) (resource, via `module.repository`)
- [tfe_registry_module.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/registry_module) (resource)
- [tfe_no_code_module.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/no_code_module) (resource)
- [tfe_test_variable.azdo_org_service_url](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [tfe_test_variable.azdo_personal_access_token](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [tfe_test_variable.azdo_project_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [tfe_test_variable.oauth_client_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [tfe_test_variable.organization](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [tfe_test_variable.tfe_token](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource)
- [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) (data source)
- [tfe_oauth_client.client](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/oauth_client) (data source)

## Outputs

The following outputs are exported:

### <a name="output_repository"></a> [repository](#output\_repository)

Description: Azure DevOps Git repository resource attributes (`id` and `name`).

### <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id)

Description: The ID of the Azure DevOps Git repository.

### <a name="output_remote_url"></a> [remote\_url](#output\_remote\_url)

Description: HTTPS clone URL of the repository.

### <a name="output_ssh_url"></a> [ssh\_url](#output\_ssh\_url)

Description: SSH clone URL of the repository.

### <a name="output_web_url"></a> [web\_url](#output\_web\_url)

Description: Web link to the repository.

### <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch)

Description: The ref of the default branch (e.g., `refs/heads/main`).

### <a name="output_branch_policy_min_reviewers"></a> [branch\_policy\_min\_reviewers](#output\_branch\_policy\_min\_reviewers)

Description: Map of minimum-reviewer branch policies keyed by branch ref.

### <a name="output_branch_policy_comment_resolution"></a> [branch\_policy\_comment\_resolution](#output\_branch\_policy\_comment\_resolution)

Description: Map of comment-resolution branch policies keyed by branch ref.

### <a name="output_branch_policy_merge_types"></a> [branch\_policy\_merge\_types](#output\_branch\_policy\_merge\_types)

Description: Map of merge-types branch policies keyed by branch ref.

### <a name="output_registry_module_id"></a> [registry\_module\_id](#output\_registry\_module\_id)

Description: The ID of the registry module.

### <a name="output_registry_module_module_provider"></a> [registry\_module\_module\_provider](#output\_registry\_module\_module\_provider)

Description: The Terraform provider that this module is used for.

### <a name="output_registry_module_name"></a> [registry\_module\_name](#output\_registry\_module\_name)

Description: The name of the registry module.

<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
