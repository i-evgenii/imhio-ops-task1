variable "vms" {
  type = "list"
  default = ["privatenet-us-vm1", "privatenet-us-vm2"]
}

# Create privatenet network
resource "google_compute_network" "privatenet" {
  name                    = "privatenet"
  auto_create_subnetworks = false
}

# Create privatesubnet-us subnetwork
resource "google_compute_subnetwork" "privatesubnet-us" {
  name                     = "privatesubnet-us"
  region                   = "us-central1"
  network                  = google_compute_network.privatenet.self_link
  ip_cidr_range            = "172.16.0.0/24"
}

# Create publicnet network
resource "google_compute_network" "publicnet" {
  name                    = "publicnet"
  auto_create_subnetworks = false
}

# Create publicsubnet-us subnetwork
resource "google_compute_subnetwork" "publicsubnet-us" {
  name                     = "publicsubnet-us"
  region                   = "us-central1"
  network                  = google_compute_network.publicnet.self_link
  ip_cidr_range            = "172.16.1.0/24"
}

# Create a firewall rule to allow all traffic on privatenet
resource "google_compute_firewall" "privatenet" {
  name    = "privatenet-allow-all"
  network = google_compute_network.privatenet.self_link
  allow {
    protocol = "all"
  }
}

# Create a firewall rule to allow tcp-8084 traffic on privatenet-us-vm1
resource "google_compute_firewall" "publicnet-tcp8084" {
  name    = "publicnet-allow-all"
  network = google_compute_network.publicnet.self_link
  allow {
    protocol = "tcp"
    ports = ["8084"]
  }
  target_tags = ["${var.vms[0]}"]
}

# Create a firewall rule to allow ssh traffic on public
resource "google_compute_firewall" "publicnet-ssh" {
  name    = "publicnet-allow-ssh"
  network = google_compute_network.publicnet.self_link
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_ranges = ["35.235.240.0/20","109.163.216.0/21"]
}

# Create a disk
resource "google_compute_disk" "vm-data-disk" {
  name = "data-disk"
  type = "pd-ssd"
  zone = "us-central1-a"
  size = 2
}

# Attach disk to VM
resource "google_compute_attached_disk" "vm-attached-data-disk" {
  disk     = google_compute_disk.vm-data-disk.id
  instance = "${var.vms[1]}"
}

# Add the 1st instance
module "privatenet-us-vm1" {
  source              = "./instance"
  instance_name       = "${var.vms[0]}"
  instance_zone       = "us-central1-a"
  instance_subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
  instance_subnetwork2 = google_compute_subnetwork.publicsubnet-us.self_link
  instance_tags = ["${var.vms[0]}"]
}

# Add the 2nd instance
module "privatenet-us-vm2" {
  source              = "./instance"
  instance_name       = "${var.vms[1]}"
  instance_zone       = "us-central1-a"
  instance_subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
  instance_subnetwork2 = google_compute_subnetwork.publicsubnet-us.self_link
  instance_tags = ["${var.vms[1]}"]
}

