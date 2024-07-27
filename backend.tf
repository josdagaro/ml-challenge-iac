terraform {
  backend "s3" {
    bucket = "bbog-ca-tf-states"
    key    = "ml.tfstate"
    region = "us-east-1"
  }
}
