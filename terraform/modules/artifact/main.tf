resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.repo_name
  description   = "Hackathon Docker repo"
  format        = "DOCKER"
  project       = var.project_id
}