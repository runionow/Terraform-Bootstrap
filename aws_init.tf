# VARIABLES

variable "aws_access_key" {
  default = "<<access-key>>"
}

variable "aws_secret_key" {
  default = "<<secret-key>>"
}

variable "private_key_path" {
  default = "C:/Users/Arun Nekkalapudi/Desktop/key1/openssh"
}

variable "key_name" {
  # type, default,description
  default = "Default Key"
}

variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "subnet_1_address_space" {
  default = "10.1.0.0/24"
}

variable "subnet_2_address_space" {
  default = "10.1.1.0/24"
}

variable "ami_amazon_docker" {
  default = "ami-922914f7" # The Amazon Linux AMI is an EBS-backed, AWS-supported image. The default image includes AWS command line tools, Python, Ruby, Perl, and Java. The repositories include Docker, PHP, MySQL, PostgreSQL, and other packages.
}

variable "billing_code_tag" {
  default = "WebServer"
}

variable "environment_tag" {
  default = "WebServer01-nginx"
}

variable "bucket_name" {
  default = "Log-WebServer"
}

# DATA SOURCE 

data "aws_availability_zones" "available" {}

# PROVIDERS 
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-2"
}

# RESOURCES
resource "aws_key_pair" "keys" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm5v3Wzqwl4LIfhTq7ECdZ0yH0aCVFFuKprHiXZJwU01RpAASqNEkbXmxMFUd4AMorprckdgkFBy9BPios4iIvouqmArVAmzrXsFDcQOGmOEUPV+jDqbaq/Oi9b4tl2ByRWhQfBfm49pxqCs+c2Zw9mYMxH78rpMNUY/1tWc4/ZVJpknI4gyUmb6TKY4nzFgRZzB6QvcjU9Q4TYi+FTDuuRQJd7rMYpZlTLiylGh2eZuuJEZHQVzUulw8awuSscAaJNOIOwIEorN8PgjXWzqNoK38PE0bxljY+jw3ab7oIDRrKY/zjl0O7fbD0F4z5viSeLO4zoGizBJ9gL4++AYH4w== rsa-key-20180621"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.network_address_space}"
  enable_dns_hostnames = "true"

  tags {
    Name        = "${var.environment_tag}-vpc"
    BillingCode = "${var.billing_code_tag}"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_internet_gateway" "i_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "public_subnet_0" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_1_address_space}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "public-subnet0"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_2_address_space}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "public-subnet1"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.i_gateway.id}"
  }
}

resource "aws_security_group" "web_server" {
  name   = "web_server"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                    = "ami-922914f7"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public_subnet_0.id}"
  key_name               = "${aws_key_pair.keys.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
    ]
  }
}

output "aws_instance_public_dns" {
  value = "${aws_instance.nginx.public_dns}"
}
