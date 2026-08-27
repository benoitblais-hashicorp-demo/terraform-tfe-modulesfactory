# The following locals block constructs derived values used throughout this configuration.

locals {
  # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>

  # display_identifier: raw (unencoded) form — HCP Terraform normalises to this on read-back,
  # so using the unencoded form prevents a perpetual diff on every plan.
  vcs_display_identifier = "${var.azuredevops_organization}/${var.azdo_project_name}/_git/${module.repository.repository.name}"

  # identifier: URL-encoded form required by the HCP Terraform API when creating/updating
  # the registry module VCS connection.
  vcs_identifier = "${var.azuredevops_organization}/${replace(var.azdo_project_name, " ", "%20")}/_git/${module.repository.repository.name}"
}

# The following data source looks up the Azure DevOps project by name to obtain its UUID,
# which is required by all azuredevops_* resources.

data "azuredevops_project" "this" {
  name = var.azdo_project_name
}

# The following block is used to get information about the OAuth client.
# The oauth_token_id (ot-...) it exposes is required by tfe_registry_module.

data "tfe_oauth_client" "client" {
  organization = var.organization
  name         = var.oauth_client_name
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
    display_identifier = local.vcs_display_identifier
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

# The following resource blocks create test variables used when running module tests in HCP Terraform.
# These mirror the variables defined in the calling workspace's variable set so that
# terraform test runs inside HCP Terraform have the same credentials available.

resource "tfe_test_variable" "azdo_org_service_url" {
  key             = "AZDO_ORG_SERVICE_URL"
  value           = data.tfe_oauth_client.client.http_url
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "azuredevops_organization" {
  key             = "TF_VAR_azuredevops_organization"
  value           = var.azuredevops_organization
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization
  sensitive       = false
}

resource "tfe_test_variable" "azdo_project_name" {
  key             = "TF_VAR_azdo_project_name"
  value           = var.azdo_project_name
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

