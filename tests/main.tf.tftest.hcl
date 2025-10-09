provider "github" {
  app_auth {} # Required when using `GITHUB_APP_XXX` environment variables
}

provider "tfe" {}

run "main_failed_security_and_analysis" {

  command = plan

  variables {
    name     = "test"
    provider = "tfe"
    security_and_analysis = {
      advanced_security = {
        status = "enabled"
      }
      secret_scanning = {
        status = "enabled"
      }
      secret_scanning_push_protection = {
        status = "enabled"
      }
    }
  }

  expect_failures = [github_repository.this]

}

run "main_passed" {

  command = apply

  variables {
    name                   = "test"
    provider               = "tfe"
  }

  assert {
    condition     = output.repository != ""
    error_message = "`repository` ouput should not be empty."
  }

  assert {
    condition     = can(regex("^.+/.+$", output.full_name))
    error_message = "`full_name` output should follow pattern \"organization_name/repository_name\"."
  }

  assert {
    condition     = can(regex("^https://github.com/.+/.+$", output.html_url))
    error_message = "`html_url` output should follow pattern \"https://github.com/organization_name/repository_name\"."
  }

  assert {
    condition     = can(regex("^git@github.com:.+/.+\\.git$", output.ssh_clone_url))
    error_message = "`ssh_clone_url` output should follow pattern \"git@github.com:organization_name/repository_name.git\"."
  }

  assert {
    condition     = can(regex("^https://github.com/.+/.+\\.git$", output.http_clone_url))
    error_message = "`http_clone_url` output should follow pattern \"https://github.com/organization_name/repository_name.git\"."
  }

  assert {
    condition     = can(regex("^git://github.com/.+/.+\\.git$", output.git_clone_url))
    error_message = "`git_clone_url` output should follow pattern git://github.com/organization_name/repository_name.git."
  }

  assert {
    condition     = can(regex("^https://github.com/.+/.+$", output.svn_url))
    error_message = "`svn_url` output should follow pattern \"https://github.com/organization_name/repository_name\"."
  }

  assert {
    condition     = output.node_id != ""
    error_message = "`node_id` output should not be empty."
  }

  assert {
    condition     = output.repo_id != ""
    error_message = "`repo_id` output should not be empty."
  }

  assert {
    condition     = output.registry_module_id != ""
    error_message = "`registry_module_id` output should not be empty."
  }

}