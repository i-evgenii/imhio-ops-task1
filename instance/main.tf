variable "instance_name" {}
variable "instance_zone" {}
variable "instance_type" {
  default = "n1-standard-1"
  }
variable "instance_subnetwork" {}

resource "google_compute_instance" "vm-instance" {
  name         = "${var.instance_name}"
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      }
  }
  network_interface {
    subnetwork = "${var.instance_subnetwork}"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_disk" "vm-data-disk" {
  name = "data-disk"
  type = "pd-ssd"
  zone = "us-central1-a"
  size = 2
}

resource "google_compute_attached_disk" "vm-attached-data-disk" {
  disk     = google_compute_disk.vm-data-disk.id
  instance = "privatenet-us-vm2"
}