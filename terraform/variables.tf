variable "project_id" {
  default = "flash-spot-478811-m2"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}
variable "credentials_json" {
  sensitive = true
}

variable "GOOGLE_CREDENTIALS" {
  type = string
}