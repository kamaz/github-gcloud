variable "project" {
  description = "The project id"
}

variable "pool" {
  description = "The pool with its name and mapping between repository and roles to apply"
  type = object({
    name = optional(string, "github-pool")
    attributes = map(object({
      type : string
      roles : list(string)
    }))
  })

  validation {
    condition     = length(keys(var.pool.attributes)) > 0
    error_message = "At least one role must be defined"
  }

  validation {
    condition = length(keys(var.pool.attributes)) > 0 && alltrue([
      for v in var.pool.attributes : contains(
        ["aud", "iss", "sub", "exp", "iat", "jti", "nbf", "actor", "actor_id", "base_ref", "environment", "event_name", "head_ref", "job_workflow_ref", "job_workflow_sha", "ref", "ref_type", "repository_visibility", "repository", "repository_id", "repository_owner", "repository_owner_id", "run_id", "run_number", "run_attempt", "runner_environment", "workflow", "workflow_ref", "workflow_sha"],
        v.type
      )
    ])
    error_message = "All roles must be defined with allowed github claims"
  }

  validation {
    condition = length(keys(var.pool.attributes)) > 0 && alltrue([
      for v in var.pool.attributes : length(v.roles) > 0
    ])
    error_message = "Roles must be defined for each attribute"
  }
}

variable "pool_providers" {
  description = "Configures providers for the workload identity pool with condition which are applied when mapping repository"
  type = map(
    object({ attribute_conditions : map(string) })
  )

  validation {
    condition     = length(keys(var.pool_providers)) > 0
    error_message = "At least one provider must be defined"
  }

  validation {
    condition = length(keys(var.pool_providers)) > 0 && alltrue([
      for v in var.pool_providers : alltrue([
        for condition in keys(v.attribute_conditions) : contains(
          ["aud", "iss", "sub", "exp", "iat", "jti", "nbf", "actor", "actor_id", "base_ref", "environment", "event_name", "head_ref", "job_workflow_ref", "job_workflow_sha", "ref", "ref_type", "repository_visibility", "repository", "repository_id", "repository_owner", "repository_owner_id", "run_id", "run_number", "run_attempt", "runner_environment", "workflow", "workflow_ref", "workflow_sha"],
          condition
        )
      ])
    ])
    error_message = "All conditions must be defined in the allowed github claims"
  }
}
