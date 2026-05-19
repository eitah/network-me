locals {
  region  = "us-central1"
  project = "itah-networking"
}

resource "google_artifact_registry_repository" "itah_networking" {
  location      = local.region
  repository_id = "toy"
  format        = "DOCKER"
}

module "origin" {
  source = "./modules/vm"
  name   = "origin"
  image  = "${local.region}-docker.pkg.dev/${local.project}/toy/origin:latest"
  tags   = ["toy", "origin"]
}

resource "google_compute_firewall" "origin" {
  name    = "allow-origin"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  target_tags   = ["origin"]
  source_ranges = ["0.0.0.0/0"]
}

module "edge" {
  source   = "./modules/nginx-proxy"
  name     = "edge"
  upstream = "${module.origin.internal_ip}:3000"
  tags     = ["toy", "edge"]
}

resource "google_compute_firewall" "edge" {
  name    = "allow-edge"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["toy", "edge"]
  source_ranges = ["0.0.0.0/0"]
}
