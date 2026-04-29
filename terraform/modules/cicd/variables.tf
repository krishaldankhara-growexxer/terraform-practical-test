variable "name_prefix" {
  description = "Prefix for CICD resource names"
  type        = string
}

variable "account_id" {
  description = "Target AWS account ID (used in S3 bucket suffix)"
  type        = string
}

variable "github_owner" {
  description = "GitHub owner / org name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
