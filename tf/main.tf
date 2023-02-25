terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  
    }
  }

  required_version = "~> 1.3.6"

  backend "s3" {
    bucket = "personal-project-remote-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "personal-project-tf-statelock"
    encrypt        = true
  }

}