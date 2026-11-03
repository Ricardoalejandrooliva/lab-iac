terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # El estado del bootstrap queda LOCAL (bootstrap/terraform.tfstate) y NO se sube a git.
}

provider "aws" {
  region = var.aws_region
}
