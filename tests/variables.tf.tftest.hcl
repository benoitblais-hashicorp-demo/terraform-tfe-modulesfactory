provider "github" {
  app_auth {} # Required when using `GITHUB_APP_XXX` environment variables
}

provider "tfe" {}

run "variables" {

  variables {
    module_name                 = "Test"
    module_provider             = "tfe"
    visibility                  = "Public"
    squash_merge_commit_title   = "PR_Title"
    squash_merge_commit_message = null
    merge_commit_title          = null
    merge_commit_message        = "PR_Body"
    security_and_analysis = {
      advanced_security = {
        status = null
      }
      secret_scanning = {
        status = "Enabled"
      }
      secret_scanning_push_protection = {
        status = "enabled"
      }
    }
  }

  command = plan

  expect_failures = [
    var.visibility,
    var.squash_merge_commit_title,
    var.squash_merge_commit_message,
    var.merge_commit_title,
    var.merge_commit_message,
    var.security_and_analysis.advanced_security.status,
    var.security_and_analysis.secret_scanning.status,
  ]

}