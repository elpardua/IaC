resource "aws_key_pair" "flugel-key-pair" {
    key_name = "flugel-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

resource "aws_instance" "web1" {

    ami = "${var.AMI}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.flugel-subnet-a.id}"
    vpc_security_group_ids = ["${aws_security_group.http-allowed.id}"]
    key_name = "${aws_key_pair.flugel-key-pair.id}"

    provisioner "file" {
        source = "nginx.sh"
        destination = "/tmp/nginx.sh"
    }

    provisioner "file" {
        source = "onbootgen.py"
        destination = "/tmp/onbootgen.py"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/nginx.sh",
            "sudo /tmp/nginx.sh"
        ]
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/onbootgen.py",
            "sudo /tmp/onbootgen.py ${aws_instance.web1.id} Name=${aws_instance.web1.tags.Name}, Owner=${aws_instance.web1.tags.Owner}"
        ]
    }

    connection {
        user = "${var.EC2_USER}"
        host = "${self.public_ip}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }

    tags = {
        Name = var.tag_name 
        Owner = var.tag_owner
    }

}

resource "aws_instance" "web2" {

    ami = "${var.AMI}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.flugel-subnet-b.id}"
    vpc_security_group_ids = ["${aws_security_group.http-allowed.id}"]
    key_name = "${aws_key_pair.flugel-key-pair.id}"

    provisioner "file" {
        source = "nginx.sh"
        destination = "/tmp/nginx.sh"
    }

    provisioner "file" {
        source = "onbootgen.py"
        destination = "/tmp/onbootgen.py"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/nginx.sh",
            "sudo /tmp/nginx.sh"
        ]
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/onbootgen.py",
            "sudo /tmp/onbootgen.py ${aws_instance.web2.id} Name=${aws_instance.web2.tags.Name}, Owner=${aws_instance.web2.tags.Owner}"
        ]
    }

    connection {
        user = "${var.EC2_USER}"
        host = "${self.public_ip}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }

    tags = {
        Name = var.tag_name
        Owner = var.tag_owner
    }
}

resource "aws_s3_bucket" "flugel-bucket" {
    acl    = "private"
    tags = {
        Name = var.tag_name
        Owner = var.tag_owner
    }
}
