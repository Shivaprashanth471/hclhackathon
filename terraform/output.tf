output "vpc_name" {
  value = module.network.vpc_name
}

output "artifact_registry_url" {
  value = module.artifact.repo_url
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}
