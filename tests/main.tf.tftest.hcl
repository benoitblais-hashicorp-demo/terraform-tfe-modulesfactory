provider "azuredevops" {
  org_service_url       = "${var.azuredevops_service_url}/${var.azuredevops_organization}"
  personal_access_token = var.azuredevops_personal_access_token
}

provider "tfe" {}

# ─────────────────────────────────────────────
# Shared mock variables required by every run.
# Set via environment variables in HCP Terraform:
#   TF_VAR_azuredevops_organization
#   TF_VAR_azuredevops_project_name
#   AZDO_PERSONAL_ACCESS_TOKEN  (or TF_VAR_azuredevops_personal_access_token)
#   TF_VAR_organization
#   TF_VAR_oauth_client_name
#   TFE_TOKEN  (or TF_VAR_tfe_token)
# ─────────────────────────────────────────────

variables {
  module_name     = "test"
  module_provider = "azurerm"
}

# ─────────────────────────────────────────────
# Run: apply and verify all key outputs.
# ─────────────────────────────────────────────

run "main_passed" {

  command = apply

  assert {
    condition     = output.repository != null
    error_message = "`repository` output should not be null."
  }

  assert {
    condition     = output.repository_id != null && output.repository_id != ""
    error_message = "`repository_id` output should not be empty."
  }

  assert {
    condition     = can(regex("^https://", output.remote_url))
    error_message = "`remote_url` output should start with \"https://\"."
  }

  assert {
    condition     = can(regex("^https://", output.web_url))
    error_message = "`web_url` output should start with \"https://\"."
  }

  assert {
    condition     = can(regex("^refs/heads/", output.default_branch))
    error_message = "`default_branch` output should follow pattern \"refs/heads/<branch>\"."
  }

  assert {
    condition     = output.registry_module_id != null && output.registry_module_id != ""
    error_message = "`registry_module_id` output should not be empty."
  }

  assert {
    condition     = output.registry_module_name != null && output.registry_module_name != ""
    error_message = "`registry_module_name` output should not be empty."
  }

  assert {
    condition     = output.registry_module_module_provider != null && output.registry_module_module_provider != ""
    error_message = "`registry_module_module_provider` output should not be empty."
  }

}
