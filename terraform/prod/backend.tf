terraform {
  backend "gcs" {
    bucket = "reddit-prod"
    prefix = "terraform/prod"
  }
}
