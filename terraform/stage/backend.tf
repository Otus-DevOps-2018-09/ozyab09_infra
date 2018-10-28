terraform {
  backend "gcs" {
    bucket = "reddit-stage"
    prefix  = "terraform/stage"
  }
}