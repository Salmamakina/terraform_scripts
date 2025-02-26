terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the GCP Provider
provider "google" {
  credentials = file("/tmp/keplerdatav1.json")
  project = "keplerdatav1"  # the GCP project ID
  region  = "us-central1"
  zone    = "us-central1-b"           
}

