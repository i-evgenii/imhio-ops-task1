variable "instance_name" {}
variable "instance_zone" {}
variable "instance_type" {
  default = "n1-standard-1"
  }
variable "instance_subnetwork" {}
variable "instance_subnetwork2" {}
variable "instance_tags" {}

resource "google_compute_instance" "vm-instance" {
  name         = "${var.instance_name}"
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"
  tags =  "${var.instance_tags}"
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = "${var.instance_subnetwork}"
    # access_config {
      # Allocate a one-to-one NAT IP to the instance
    # }
  }
  network_interface {
    subnetwork = "${var.instance_subnetwork2}"
    access_config {
      // Ephemeral IP
    }
  }
  lifecycle {
    ignore_changes = [attached_disk]
  }
}

