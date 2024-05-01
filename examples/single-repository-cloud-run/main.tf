locals {
  repository = "replace me with repository e.g. kamaz/terraform-google-github"
  project_id = "replace me with google cloud project id"
}

module "gcloud_github" {
  source = "../../"

  project = local.project_id

  pool = {
    name = "github"
    attributes = {
      "${local.repository}" = {
        type  = "repository"
        roles = ["roles/run.admin"]
      }
    }
  }

  pool_providers = {
    "provider" = {
      attribute_conditions = {
        "repository" = local.repository
      }
    }
  }
}
