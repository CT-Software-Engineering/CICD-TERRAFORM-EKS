terraform {
  backend "s3" {
    bucket = "terraform-state-awake"
    key    = "eks/terraform.tfstate"
    region = "eu-west-1"
  }
}