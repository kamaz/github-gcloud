locals {
  # Set of supported claims that can be used in the assertion
  # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token
  supported_claims = [
    "aud",                   # Audience	By default, this is the URL of the repository owner, such as the organization that owns the repository. You can set a custom audience with a toolkit command: core.getIDToken(audience)
    "iss",                   # Issuer	The issuer of the OIDC token: https://token.actions.githubusercontent.com
    "sub",                   # Subject	Defines the subject claim that is to be validated by the cloud provider. This setting is essential for making sure that access tokens are only allocated in a predictable way.
    "exp",                   # Expires at	Identifies the expiry time of the JWT.
    "iat",                   # Issued at	The time when the JWT was issued.
    "jti",                   # JWT token identifier	Unique identifier for the OIDC token.
    "nbf",                   # Not before	JWT is not valid for use before this time.
    "actor",                 # The personal account that initiated the workflow run.
    "actor_id",              # The ID of personal account that initiated the workflow run.
    "base_ref",              # The target branch of the pull request in a workflow run.
    "environment",           # The name of the environment used by the job. To include the environment claim you must reference an environment.
    "event_name",            # The name of the event that triggered the workflow run.
    "head_ref",              # The source branch of the pull request in a workflow run.
    "job_workflow_ref",      # For jobs using a reusable workflow, the ref path to the reusable workflow. For more information, see "Using OpenID Connect with reusable workflows."
    "job_workflow_sha",      # For jobs using a reusable workflow, the commit SHA for the reusable workflow file.
    "ref",                   # (Reference) The git ref that triggered the workflow run.
    "ref_type",              #	The type of ref, for example: "branch".
    "repository_visibility", # The visibility of the repository where the workflow is running. Accepts the following values: internal, private, or public.
    "repository",            # The repository from where the workflow is running.
    "repository_id",         # The ID of the repository from where the workflow is running.
    "repository_owner",      # The name of the organization in which the repository is stored.
    "repository_owner_id",   # The ID of the organization in which the repository is stored.
    "run_id",                # The ID of the workflow run that triggered the workflow.
    "run_number",            # The number of times this workflow has been run.
    "run_attempt",           # The number of times this workflow run has been retried.
    "runner_environment",    # The type of runner used by the job. Accepts the following values: github-hosted or self-hosted.
    "workflow",              # The name of the workflow.
    "workflow_ref",          # The ref path to the workflow. For example, octocat/hello-world/.github/workflows/my-workflow.yml@refs/heads/my_branch.
    "workflow_sha",          # The commit SHA for the workflow file.
  ]
}

resource "google_iam_workload_identity_pool" "main" {
  project = var.project

  workload_identity_pool_id = var.pool.name
  display_name              = "Github of pool"
  description               = "Identity pool for github workflow integration"
}

resource "google_iam_workload_identity_pool_provider" "main" {
  for_each = var.pool_providers

  project = var.project


  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.pool.name}-${each.key}"

  attribute_mapping = merge({
    "google.subject" = "assertion.sub"
  }, { for k, v in each.value.attribute_conditions : "attribute.${k}" => "assertion.${k}" })

  attribute_condition = join(" && ", [for k in sort(keys(each.value.attribute_conditions)) : "assertion.${k} == ${each.value.attribute_conditions[k]}"])

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_project_iam_binding" "main" {
  for_each = { for role in flatten([for attribute, v in var.pool.attributes :
    [for role in v.roles : { role = role, attribute = attribute, type = v.type }]
    ]) :
    "${role.attribute}-${role.role}" => {
      role      = role.role
      attribute = role.attribute
      type      = role.type
    }
  }

  project = var.project

  role = each.value.role

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.${each.value.type}/${each.value.attribute}"
  ]
}
