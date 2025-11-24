variable "project_id" {
     type = string 
}

variable "region" { 
    type = string
}

variable "cluster_name" { 
    type = string 
}

variable "network" { 
    type = string
}

variable "subnetwork" {
     type = string
}

variable "pods_range_name" {
     type = string 
}

variable "services_range_name" {
     type = string
}

variable "node_sa_email" { 
    type = string 
}

variable "node_count" { 
    type = number
}
