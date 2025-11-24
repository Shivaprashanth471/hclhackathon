variable "project_id" {
  type = string
}
variable "node_sa_name" {
  type = string
}

variable "ci_cd_sa_name" {
  type        = string
  description = "Service account ID for CI/CD pipelines"
  default     = "github-actions-sa"
}
