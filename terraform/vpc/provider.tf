terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
# Remote Backend
  backend "s3" {
    bucket         = "01-eks-karpenter-demo"
    key            = "vpc/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
    profile        = "eks-demo-cloudops"
  }   
}

provider "aws" {
  region  = var.aws_region
  profile = "eks-demo-cloudops"
}