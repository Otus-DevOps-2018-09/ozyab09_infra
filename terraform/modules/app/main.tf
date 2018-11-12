resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "f1-micro"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }


  #  connection {
  #    type        = "ssh"
  #    user        = "appuser"
  #    agent       = false
  #    private_key = "${var.private_key_path}"
  #  }

  #  provisioner "file" {
  #    source      = "../modules/app/puma.service"
  #    destination = "/tmp/puma.service"
  #  }

  #  provisioner "file" {
  #    source      = "../modules/app/deploy.sh"
  #    destination = "deploy.sh"
  #  }

  #  provisioner "remote-exec" {
  #    script = "deploy.sh ${var.db_ip}"
  #  }

}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
