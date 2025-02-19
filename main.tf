resource "google_compute_network" "custom_network" {
  name                    = "my-custom-network"
  auto_create_subnetworks  = false
}


resource "google_compute_subnetwork" "custom_subnetwork" {
  name          = "subnet-custom"
  ip_cidr_range = "10.1.0.0/24"
  network       = google_compute_network.custom_network.self_link
  region        = "us-central1"
}

# Création des adresses IP statiques pour la VM master
resource "google_compute_address" "master_ip_internal" {
    name         = "master-ip-internal"
    address_type = "INTERNAL"
    subnetwork   = google_compute_subnetwork.custom_subnetwork.self_link
    region       = "us-central1"
  }

resource "google_compute_address" "master_ip_external" {
    name         = "master-ip-external"
    address_type = "EXTERNAL"
    region       = "us-central1"
  }


resource "google_compute_instance" "master" {
  name         = "master-vm-test"
  machine_type = "n2-standard-2"  
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image        = "ubuntu-2204-jammy-v20250128"
      size          = 50
    }
  }
  
  network_interface {
    network    = google_compute_network.custom_network.self_link
    subnetwork = google_compute_subnetwork.custom_subnetwork.self_link
    network_ip = google_compute_address.master_ip_internal.address

    access_config {
      nat_ip = google_compute_address.master_ip_external.address
    }
  } 

 tags = ["internal-communication", "allow-inbound-traffic"]

}

# Communication interne entre les VMs
resource "google_compute_firewall" "internal_communication" {
  name    = "allow-internal-vm"
  network = google_compute_network.custom_network.name

  allow {
    protocol = "all"  # Permet tous les protocoles
  }

  source_ranges = ["10.1.0.0/24"] 
  target_tags   = ["internal-communication"] 
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-inbound-traffic"
  network = google_compute_network.custom_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3001", "5001", "80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Autoriser SSH depuis n'importe où (à restreindre si besoin)
  target_tags   = ["allow-inbound-traffic"]
}




####### worker vm
# Création des adresses IP statiques pour la VM worker
resource "google_compute_address" "worker_ip_internal" {
    name         = "worker-ip-internal"
    address_type = "INTERNAL"
    subnetwork   = google_compute_subnetwork.custom_subnetwork.self_link
    region       = "us-central1"
  }

resource "google_compute_address" "worker_ip_external" {
    name         = "worker-ip-external"
    address_type = "EXTERNAL"
    region       = "us-central1"
  }


resource "google_compute_instance" "worker" {
  name         = "worker-vm-test"
  machine_type = "n2-standard-2" 
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image        = "ubuntu-2204-jammy-v20250128"
      size          = 50
    }
  }
  
  network_interface {
    network    = google_compute_network.custom_network.self_link
    subnetwork = google_compute_subnetwork.custom_subnetwork.self_link
    network_ip = google_compute_address.worker_ip_internal.address

    access_config {
      nat_ip = google_compute_address.worker_ip_external.address
    }
  } 
  
  tags = ["internal-communication", "allow-inbound-traffic"]


}
