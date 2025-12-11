output "cloudrun_deployer_sa_email" {
  description = "Email of the Cloud Run deployer service account"
  value       = google_service_account.cloudrun_deployer.email
}

output "cloudrun_runtime_sa_email" {
  description = "Email of the Cloud Run runtime service account"
  value       = google_service_account.cloudrun_runtime.email
}

output "artifact_registry_repo" {
  description = "Artifact Registry Docker repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "artifact_registry_repo_url" {
  description = "Docker repository URL for tagging & pushing images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}
