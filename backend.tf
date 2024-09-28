terraform {
  backend "s3" {
    key     = "ecs/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
