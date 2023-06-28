provider "aws" {
  region  = "eu-central-1"
  profile = "mine"
}

locals {
  tags = {
    managedBy   = "terraform",
    Owner       = "inemyrovsk",
    Project     = var.project
    Environment = terraform.workspace
  }
}