variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "poised-ceiling-480200-m7"
}

variable "region" {
  description = "GCP region for Artifact Registry & Cloud Run"
  type        = string
  default     = "us-central1"
}

variable "repo_id" {
  description = "Artifact Registry repository ID (name)"
  type        = string
  default     = "cloudrun-demo-repo"
}

variable "enable_artifact_registry_writer" {
  description = "Whether to grant Artifact Registry writer role to the deployer SA"
  type        = bool
  default     = true
}
