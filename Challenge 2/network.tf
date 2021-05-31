#Subnet for availability zone A
resource "aws_subnet" "flugel-subnet-a" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
    cidr_block = "10.0.40.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2a"
}

#Subnet for availability zone B
resource "aws_subnet" "flugel-subnet-b" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
    cidr_block = "10.0.20.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2b"
}

#VPC's Internet Gateway
resource "aws_internet_gateway" "flugel-igw" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
}

#VPC's Routing Table
resource "aws_route_table" "flugel-default-gw" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.flugel-igw.id}"
    }
}

#Default Gateway route association AZ A
resource "aws_route_table_association" "flugel-crta-subnet-a" {
    subnet_id = "${aws_subnet.flugel-subnet-a.id}"
    route_table_id = "${aws_route_table.flugel-default-gw.id}"
}

#Default Gateway route association AZ B
resource "aws_route_table_association" "flugel-crta-subnet-b" {
    subnet_id = "${aws_subnet.flugel-subnet-b.id}"
    route_table_id = "${aws_route_table.flugel-default-gw.id}"
}

#Then we create the Application Load Balancer
resource "aws_alb" "flugel-alb" {
  name               = "flugel-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-http-allowed.id]
  subnets            = [aws_subnet.flugel-subnet-a.id, aws_subnet.flugel-subnet-b.id]
  enable_deletion_protection = false

  #Access Logs will be stored on a private bucket 
  access_logs {
      bucket = "flugel-bucket"
      prefix = "ALB-Logs"
  }
}

#Now let's create a listener on port 80 for the ALB
resource "aws_lb_listener" "flugel-alb-http-listener" {
  load_balancer_arn = aws_alb.flugel-alb.arn

  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flugel-alb-tg.arn
  }
}

#We should define an instance pool to target the traffic from the LB
resource "aws_lb_target_group" "flugel-alb-tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.flugel-vpc.id

  load_balancing_algorithm_type = "round_robin"

  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  depends_on = [
    aws_alb.flugel-alb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#To complete the ALB deploy, we must register the targets.
resource "aws_lb_target_group_attachment" "flugel-targets-a" {
  target_group_arn = aws_lb_target_group.flugel-alb-tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "flugel-targets-b" {
  target_group_arn = aws_lb_target_group.flugel-alb-tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}



#Security group for direct access to instances, mainly MGMT traffic
resource "aws_security_group" "http-allowed" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.MGMT_IP}"]
    }
    ingress {
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Instances MGMT SG"
    }
}

#Security group for the ALB
resource "aws_security_group" "lb-http-allowed" {
    vpc_id = "${aws_vpc.flugel-vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "HTTP Load Balancer SG"
    }
}
