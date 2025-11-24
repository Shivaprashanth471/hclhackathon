resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "private" {
  name                  = "${var.vpc_name}-private"
  ip_cidr_range         = var.private_subnet_cidr
  region                = var.region
  project               = var.project_id
  network               = google_compute_network.vpc.self_link
  purpose               = "PRIVATE"
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.pods_secondary_cidr
  }
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_secondary_cidr
  }
}

resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


