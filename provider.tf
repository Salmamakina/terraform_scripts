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
  credentials = "keplerdata.json"
  project = "keplerdatav1"  # the GCP project ID
  region  = "us-central1"
  zone    = "us-central1-a"           
}
