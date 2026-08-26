# The following locals block constructs derived values used throughout this configuration.

locals {
  # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
  # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
  azdo_org_service_url = "${var.azuredevops_service_url}/${var.azuredevops_organization}"
  vcs_identifier       = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.repository.repository.name}"
}

# The following data source looks up the Azure DevOps project by name to obtain its UUID,
# which is required by all azuredevops_* resources.

data "azuredevops_project" "this" {
  name = var.azuredevops_project_name
}

# The following module block is used to create and manage the Azure DevOps repository.

module "repository" {
  source          = "./modules/azuredevops_repository"
  name            = lower("terraform-${var.module_provider}-${var.module_name}")
  project_id      = data.azuredevops_project.this.id
  default_branch  = var.default_branch
  disabled        = var.disabled
  initialization  = var.initialization
  branch_policies = var.branch_policies
}

# The following code block is used to create module resources in the private registry.

resource "tfe_registry_module" "this" {
  organization    = var.organization
  initial_version = "0.0.0"
  test_config {
    tests_enabled = true
  }
  vcs_repo {
    display_identifier = local.vcs_identifier
    identifier         = local.vcs_identifier
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
    branch             = var.default_branch
  }
}

resource "tfe_no_code_module" "this" {
  count           = var.no_code_module ? 1 : 0
  organization    = var.organization
  registry_module = tfe_registry_module.this.id
}

# The following block is used to get information about an OAuth client.

data "tfe_oauth_client" "client" {
  organization = var.organization
  name         = var.oauth_client_name
}

# The following resource blocks create test variables used when running module tests in HCP Terraform.

resource "tfe_test_variable" "azdo_org_service_url" {
  key             = "AZDO_ORG_SERVICE_URL"
  value           = local.azdo_org_service_url
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "azdo_personal_access_token" {
  key             = "AZDO_PERSONAL_ACCESS_TOKEN"
  value           = var.azuredevops_personal_access_token
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = true
}

resource "tfe_test_variable" "azdo_project_name" {
  key             = "TF_VAR_azdo_project_name"
  value           = var.azuredevops_project_name
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "oauth_client_name" {
  key             = "TF_VAR_oauth_client_name"
  value           = var.oauth_client_name
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "organization" {
  key             = "TF_VAR_organization"
  value           = var.organization
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "tfe_token" {
  key             = "TFE_TOKEN"
  value           = var.tfe_token
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = true
}
