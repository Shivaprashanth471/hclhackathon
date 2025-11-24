resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary" {
  name       = "default-pool"
  cluster    = google_container_cluster.cluster.name
  location   = var.region
  node_count = var.node_count
  project    = var.project_id

  node_config {
    machine_type    = "e2-standard-4"
    service_account = var.node_sa_email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels = {
      env = "dev"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}
