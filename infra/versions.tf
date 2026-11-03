terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # El bucket se pasa en el init: -backend-config="bucket=..."
  backend "s3" {
    key          = "lab-iac/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # bloqueo nativo en S3 (Terraform 1.10+), sin DynamoDB
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
