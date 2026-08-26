provider "azuredevops" {
  org_service_url       = "${var.azuredevops_service_url}/${var.azuredevops_organization}"
  personal_access_token = var.azuredevops_personal_access_token
}

provider "tfe" {}

# ─────────────────────────────────────────────────────────────────────────────
# Test: invalid values for variables that have validation rules.
# Each sub-run below triggers exactly the validation(s) listed in expect_failures.
# ─────────────────────────────────────────────────────────────────────────────

# --- initialization.init_type ------------------------------------------------

run "variables_initialization_invalid_init_type" {

  command = plan

  variables {
    module_name     = "test"
    module_provider = "azurerm"
    initialization = {
      init_type  = "BadType"
      source_url = null
    }
  }

  expect_failures = [
    var.initialization,
  ]

}

run "variables_initialization_import_missing_source_url" {

  command = plan

  variables {
    module_name     = "test"
    module_provider = "azurerm"
    initialization = {
      init_type  = "Import"
      source_url = null
    }
  }

  expect_failures = [
    var.initialization,
  ]

}

# --- branch_policies[*].match_type -------------------------------------------

run "variables_branch_policies_invalid_match_type" {

  command = plan

  variables {
    module_name     = "test"
    module_provider = "azurerm"
    branch_policies = [
      {
        branch_ref = "refs/heads/main"
        match_type = "InvalidMatchType"
      }
    ]
  }

  expect_failures = [
    var.branch_policies,
  ]

}
