terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }

  backend "s3" {
    bucket         = "d4ml-terraform-eu-west-1"
    key            = "ll-scripting.tfstate"
    dynamodb_table = "ll-scripting-table"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-1:823164954914:key/668b0a69-e762-4bc8-89ff-ba8c28ecbde2"
    region         = "eu-west-1"
  }

}

provider "aws" {
  # Configuration options
  region  = "eu-central-1"
  profile = "d4ml-intern"
}

