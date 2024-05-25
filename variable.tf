variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "eat-restaurant-bootstrap-bucket" # Replace with your desired bucket name
}

variable "deployer_key_name" {
  description = "Name of the key pair"
  default     = "deployer-key"
}

