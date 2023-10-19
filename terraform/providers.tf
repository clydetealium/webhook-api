provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Purpose = "POC"
      POC     = "webhook api"
      Owner   = "Clyde"
    }
  }
}
