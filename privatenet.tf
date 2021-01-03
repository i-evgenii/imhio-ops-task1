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
  private_ip_google_access = true
}

# Create a firewall rule to allow all traffic on privatenet
resource "google_compute_firewall" "privatenet" {
  name    = "privatenet-allow-all"
  network = google_compute_network.privatenet.self_link
  allow {
    protocol = "all"
  }
}

resource "google_compute_disk" "default" {
  name = "data-disk"
  type = "pd-ssd"
  zone = "us-central1-a"
  size = 2
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = "privatenet-us-vm2"
}

# Add the privatenet-us-vm instance
module "privatenet-us-vm1" {
  source              = "./instance"
  instance_name       = "privatenet-us-vm1"
  instance_zone       = "us-central1-a"
  instance_subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
}

# Add the privatenet-us-vm instance
module "privatenet-us-vm2" {
  source              = "./instance"
  instance_name       = "privatenet-us-vm2"
  instance_zone       = "us-central1-a"
  instance_subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
}