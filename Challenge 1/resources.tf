resource "aws_s3_bucket" "flugelbucket" {
  acl    = "private"

  tags = {
    Name = var.tag_name
    Owner = var.tag_owner
  }
}

resource "aws_instance" "flugelinstance" {
  ami = "ami-077e31c4939f6a2f3"
  instance_type = "t2.micro"

  tags = {
    Name = var.tag_name
    Owner = var.tag_owner
  }
}


