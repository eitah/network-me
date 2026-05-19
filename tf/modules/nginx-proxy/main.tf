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

  metadata = {
    nginx-conf = templatefile("${path.module}/nginx.conf.tftpl", { UPSTREAM = var.upstream })
    startup-script = <<-EOF
      #!/bin/bash
      set -eo pipefail
      mkdir -p /var/lib/nginx
      curl -sf -H "Metadata-Flavor: Google" \
        http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-conf \
        > /var/lib/nginx/default.conf
      docker run -d --restart=always --name nginx-proxy \
        -p 80:80 \
        -v /var/lib/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro \
        nginx
    EOF
  }
}
