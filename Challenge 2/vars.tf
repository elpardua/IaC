variable "AWS_REGION" {
  default = "us-east-2"
}

variable "tag_name" {
  default = "Flugel"
}

variable "tag_owner" {
  default = "InfraTeam"
}

variable "PRIVATE_KEY_PATH" {
  default = "flugel-key-pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "flugel-key-pair.pub"
}

variable "EC2_USER" {
  default = "ec2-user"
}

variable "AMI" {
  default = "ami-077e31c4939f6a2f3"
}

variable "MGMT_IP" {
  default = "181.46.58.198/32"
}
