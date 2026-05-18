locals {
  registry_host = regex("^([^/]+)/", var.image)[0]
}

resource "google_service_account" "vm" {
  account_id   = "${var.name}-vm"
  display_name = "${var.name} VM"
}

resource "google_project_iam_member" "ar_reader" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm.email}"
}

data "google_project" "current" {}

resource "google_compute_instance" "this" {
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 10
    }
  }

  network_interface {
    network = var.network
    access_config {}
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOF
    #!/bin/bash
    set -eo pipefail
    HOME=/home/chronos docker-credential-gcr configure-docker --registries=${local.registry_host}
    HOME=/home/chronos docker pull ${var.image}
    docker run -d --restart=always -p ${var.port}:${var.port} \
      -e PORT=${var.port} \
      --name origin \
      ${var.image}
    EOF
  }
}
