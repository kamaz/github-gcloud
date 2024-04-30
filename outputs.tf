locals {
  gcloud_jobs = {
    for k, v in google_iam_workload_identity_pool_provider.main :
    k => {
      runs-on : "ubuntu-latest"
      steps : [
        {
          name : "Checkout"
          uses : "actions/checkout@v4"
        },
        {
          name : "Google Cloud Credentials"
          uses : "google-github-actions/auth@v2"
          with : {
            project_id : var.project
            workload_identity_provider : v.name
          }
        },
        {
          name : "Google Cloud CLI"
          run : "gcloud # replace with service you want to run e.g. (run services list)"
        }
      ]
    }
  }

  debug_job = {
    debug : {
      runs-on : "ubuntu-latest"
      steps : [
        {
          name : "Checkout actions-oidc-debugger"
          uses : "actions/checkout@v4"
          with : {
            repository : "github/actions-oidc-debugger"
            ref : "main"
            path : "./.github/actions/actions-oidc-debugger"
            token : "$${{ secrets.GITHUB_TOKEN }}"
          }
        },
        {
          name : "Debug OIDC Claims"
          uses : "./.github/actions/actions-oidc-debugger"
          with : {
            audience : "https://github.com/github"
          }
        }
      ]
    }
  }

  github_gcp_template = {
    name : "Github <> GCP Template"
    on : {
      pull_request : {
        branches : ["main"]
      }
      push : {
        branches : ["main"]
      }
    }
    permissions : {
      id-token : "write" # This is required for requesting the JWT
      contents : "read"  # This is required for actions/checkout
    }
    jobs : merge(local.gcloud_jobs, local.debug_job)
  }
}

output "github_template" {
  value = yamlencode(local.github_gcp_template)
}
