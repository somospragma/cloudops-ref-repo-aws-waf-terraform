###########################################
#Version definition - Terraform - Providers
###########################################

# provider "aws" {
#   region  = var.aws_region
#   profile = var.profile

#   default_tags {
#     tags = var.common_tags
#   }
# }

provider "aws" {
  alias   = "project"
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = ">= 1.11.4"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">=5.96.0"
      configuration_aliases = [aws.project]
    }
  }
}