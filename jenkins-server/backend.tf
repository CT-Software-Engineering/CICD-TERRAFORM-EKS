terraform {
  backend "s3" {
    bucket = "terraform-state-awake"
    key    = "jenkins/terraform.tfstate"
    region = "eu-west-1"
  }
}