# Github <> Google Cloud

Terraform modules to enable OIDC authentication between github and google cloud.

For detail instructions refer to the [examples](./examples/) directory.

## Current Limitation

This option is not supported by `Firebase Admin SDK`. Use Service Account Key JSON authentication instead.

Using "name" fields like repository and repository_owner increases the chances of cybersquatting and typosquatting attacks. If you delete your GitHub repository or GitHub organization, someone may be able to claim that same name and establish an identity. To protect against this situation, use the numeric \*\_id fields instead, which are unique and can't be reused.

## Resources

- [Terraform Module](https://developer.hashicorp.com/terraform/tutorials/modules)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Configure Workload Identity Federation with deployment pipelines](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)
- [Google GitHub Action](https://github.com/google-github-actions/auth)
