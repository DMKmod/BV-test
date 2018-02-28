provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "web-asg" {
  launch_configuration = "${aws_launch_configuration.web-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 4

  load_balancers = ["${aws_elb.web-lb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "web-lc" {
  name_prefix	= "web-lc-"
  image_id 	= "ami-5055cd3f"
  instance_type = "t2.micro"
  key_name	= "BV"
  security_groups = ["${aws_security_group.web-instances.id}"]

#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt-get -y update",
#      "sudo apt-get -y install nginx",
#    ]
#  }
#  provisioner "file" {
#    source = "BV-test/index.html"
#    destination = "/var/www/html/index.html"
#  }


  user_data = <<-EOF
  #!/bin/bash
  apt-get -y update
  apt-get -y install nginx
  git clone https://github.com/DMKmod/index.git /home/ubuntu/index
  cp /home/ubuntu/index/index.html /var/www/html
  ufw allow 'Nginx HTTP'
  ufw allow 'OpenSSH'
  yes | ufw enable
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web-instances" {
  name = "web-instances"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web-lb" {
  name = "web-lb"
  security_groups = ["${aws_security_group.web-elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold = "10"
    unhealthy_threshold = "2"
    timeout = "5"
    interval = "30"
    target = "TCP:80"
  }

  listener {
    lb_port = "80"
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

resource "aws_security_group" "web-elb" {
  name = "web-elb"

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
