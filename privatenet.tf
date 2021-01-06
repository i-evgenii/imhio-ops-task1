variable "vms" {
  type    = list(string)
  default = ["privatenet-us-vm1", "privatenet-us-vm2"]
}

# Create privatenet network
resource "google_compute_network" "privatenet" {
  name                    = "privatenet"
  auto_create_subnetworks = false
}

# Create privatesubnet-us subnetwork
resource "google_compute_subnetwork" "privatesubnet-us" {
  name          = "privatesubnet-us"
  region        = "us-central1"
  network       = google_compute_network.privatenet.self_link
  ip_cidr_range = "172.16.0.0/24"
}

# Create publicnet network
resource "google_compute_network" "publicnet" {
  name                    = "publicnet"
  auto_create_subnetworks = false
}

# Create publicsubnet-us subnetwork
resource "google_compute_subnetwork" "publicsubnet-us" {
  name          = "publicsubnet-us"
  region        = "us-central1"
  network       = google_compute_network.publicnet.self_link
  ip_cidr_range = "172.16.1.0/24"
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
    ports    = ["8084"]
  }
  target_tags = ["${var.vms[0]}"]
}

# Create a firewall rule to allow ssh traffic on public
resource "google_compute_firewall" "publicnet-ssh" {
  name    = "publicnet-allow-ssh"
  network = google_compute_network.publicnet.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20", "109.163.216.0/21"]
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
  instance = element(google_compute_instance.vm-instance2.*.self_link, 0)
}

# Create the 1st VM
resource "google_compute_instance" "vm-instance1" {
  name         = var.vms[0]
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"
  tags         = ["${var.vms[0]}"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.publicsubnet-us.self_link
    access_config {
      // Ephemeral IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
  }
  lifecycle {
    ignore_changes = [attached_disk]
  }
}

# Create the 2nd VM
resource "google_compute_instance" "vm-instance2" {
  name         = var.vms[1]
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"
  tags         = ["${var.vms[1]}"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.publicsubnet-us.self_link
    access_config {
      // Ephemeral IP
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

