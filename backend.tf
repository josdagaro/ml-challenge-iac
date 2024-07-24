terraform {
  backend "s3" {
    bucket = "your-bucket-name"
    key    = "path/to/your/key"
    region = "us-east-1"
  }
}
