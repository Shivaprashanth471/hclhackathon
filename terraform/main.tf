terraform {
  cloud {
    organization = "tlz-venk"
    workspaces {
      name = "terraform-demo"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
       version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.credentials_json
}

# Network (VPC + subnets + NAT)
module "network" {
  source                = "./modules/network"
  project_id            = var.project_id
  region                = var.region
  vpc_name              = "hackathon-vpc"
  #public_subnet_cidr    = "10.10.0.0/20"
  private_subnet_cidr   = "10.10.16.0/20"
  pods_secondary_cidr   = "10.20.0.0/16"
  services_secondary_cidr = "10.21.0.0/20"
}

# Artifact Registry
module "artifact" {
  source      = "./modules/artifact"
  project_id  = var.project_id
  region      = var.region
  repo_name   = "hackathon-repo"
}

# IAM for node SA
module "iam" {
  source             = "./modules/iam"
  project_id         = var.project_id
  node_sa_name       = "gke-node-sa"
}

# GKE cluster
module "gke" {
   source                = "./modules/gke"
  project_id             = var.project_id
  region                 = var.region
  cluster_name           = "hackathon-gke-dev"
  network                = module.network.vpc_self_link
  subnetwork             = module.network.private_subnet_self_link
  pods_range_name        = module.network.pods_range_name
  services_range_name    = module.network.services_range_name
  node_sa_email          = module.iam.node_sa_email
  node_count             = 3
}
