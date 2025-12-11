terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -----------------------------
# Enable required APIs
# -----------------------------
resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

# -----------------------------
# Artifact Registry (Docker, regional)
# -----------------------------
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repo_id
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifactregistry
  ]
}

# -----------------------------
# Service Accounts
# -----------------------------

# Dedicated deployer for Cloud Run (used by GitHub Actions / CI)
resource "google_service_account" "cloudrun_deployer" {
  account_id   = "cloudrun-deployer"
  display_name = "Cloud Run Deployer SA"
}

# Runtime service account for Cloud Run services
# (this is the one your Cloud Run service will run as)
resource "google_service_account" "cloudrun_runtime" {
  account_id   = "cloudrun-runtime"
  display_name = "Cloud Run Runtime SA"
}

# -----------------------------
# IAM Bindings
# -----------------------------

# Allow deployer SA to deploy/update Cloud Run services
resource "google_project_iam_member" "cloudrun_deployer_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.cloudrun_deployer.email}"
}

# Allow deployer SA to "act as" the runtime SA (least privilege)
resource "google_service_account_iam_member" "deployer_act_as_runtime" {
  service_account_id = google_service_account.cloudrun_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudrun_deployer.email}"
}

# (Optional) If CI/CD needs to push to Artifact Registry, give writer role
resource "google_project_iam_member" "artifactregistry_writer" {
  count   = var.enable_artifact_registry_writer ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudrun_deployer.email}"

  depends_on = [
    google_artifact_registry_repository.docker_repo
  ]
}
