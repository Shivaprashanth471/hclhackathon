output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}
output "private_subnet_self_link" {
  value = google_compute_subnetwork.private.self_link
}
output "pods_range_name" {
  value = "pods-range"
}
output "services_range_name" {
  value = "services-range"
}
output "vpc_name" {
  value = var.vpc_name
}

