variable "github_owner" {
  type        = string
  description = "The GitHub owner"
  default     = "srudyka"
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
}

variable "flux_github_repo" {
  type        = string
  default     = "flux-gitops"
  description = "GitHub repository"
}
variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "demo"
}
