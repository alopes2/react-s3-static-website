terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-medium-api-notification"
    key    = "react_s3_static_website.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

