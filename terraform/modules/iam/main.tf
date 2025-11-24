# Existing Node SA (for GKE nodes)
resource "google_service_account" "node" {
  account_id   = var.node_sa_name
  display_name = "GKE node service account"
  project      = var.project_id
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.node.email}"
}

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.node.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.node.email}"
}



# NEW: CI/CD Service Account (for GitHub Actions)
resource "google_service_account" "ci_cd" {
  account_id   = var.ci_cd_sa_name
  display_name = "GitHub Actions CI/CD Service Account"
  project      = var.project_id
}

# Roles for CI/CD SA
resource "google_project_iam_member" "ci_cd_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

resource "google_project_iam_member" "ci_cd_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

resource "google_project_iam_member" "ci_cd_cluster_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

output "ci_cd_sa_email" {
  value = google_service_account.ci_cd.email
}
