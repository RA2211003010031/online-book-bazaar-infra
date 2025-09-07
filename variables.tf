variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "AWS EC2 key pair name (without .pem extension)"
  type        = string
  default     = "team-key-mumbai"
}
