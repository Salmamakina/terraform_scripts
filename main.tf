resource "google_compute_network" "jenkins_network" {
  name                    = "jenkins-network"
  auto_create_subnetworks  = false
}


resource "google_compute_subnetwork" "jenkins_subnetwork" {
  name          = "subnet-jenkins"
  ip_cidr_range = "10.2.0.0/24"
  network       = google_compute_network.jenkins_network.self_link
  region        = "us-central1"
}

# Création des adresses IP statiques pour la VM master
resource "google_compute_address" "jenkins_internal" {
    name         = "jenkins-internal"
    address_type = "INTERNAL"
    subnetwork   = google_compute_subnetwork.jenkins_subnetwork.self_link
    region       = "us-central1"
  }

resource "google_compute_address" "jenkins_external" {
    name         = "jenkins-external"
    address_type = "EXTERNAL"
    region       = "us-central1"
  }


resource "google_compute_instance" "jenkins" {
  name         = "jenkins-vm-test"
  machine_type = "e2-micro"  
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image        = "ubuntu-2204-jammy-v20250128"
      size          = 10
    }
  }
  
  network_interface {
    network    = google_compute_network.jenkins_network.self_link
    subnetwork = google_compute_subnetwork.jenkins_subnetwork.self_link
    network_ip = google_compute_address.jenkins_internal.address

    access_config {
      nat_ip = google_compute_address.jenkins_external.address
    }
  } 

 tags = ["allow-jenkins-traffic"]

}
metadata = {
    block-project-ssh-keys = true  # Désactiver les clés SSH globales
  }

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-jenkins-traffic"
  network = google_compute_network.jenkins_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3001", "5001", "80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Autoriser SSH depuis n'importe où (à restreindre si besoin)
  target_tags   = ["allow-jenkins-traffic"]
}
