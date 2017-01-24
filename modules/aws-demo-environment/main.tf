# -----------------------------------------------
#  AWS : Networking Resources
# -----------------------------------------------
resource "aws_vpc" "demovpc" {
  cidr_block = "10.20.100.0/24"
  enable_dns_hostnames = true

  tags {
    Name    = "letfdemo-vpc"
    Purpose = "letfdemo"
  }
}

# Internet gateway gives subnet access to the internet
resource "aws_internet_gateway" "demovpc-ig" {
  vpc_id = "${aws_vpc.demovpc.id}"
  tags {
    Name = "letfdemo-ig"
    Purpose = "letfdemo"    
  }
}

# Ensure VPC can access internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.demovpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demovpc-ig.id}"

}

# Create a subnet for our instances 
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block              = "10.20.100.32/27"
  map_public_ip_on_launch = true

  tags {
    Name = "letfdemo-subnet"
    Purpose = "letfdemo"    
  }
}

# ------------------------------------------
#  AWS : ELB related config
# ------------------------------------------

# ELB security group (ensure its accessible via the web)
resource "aws_security_group" "elb" {
  name        = "letfdemo-sg-elb"
  description = "ELB security group"
  vpc_id      = "${aws_vpc.demovpc.id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
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

  tags {
    Name = "letfdemo-sg-elb"
    Purpose = "letfdemo"    
  }
}

resource "aws_iam_server_certificate" "elb_cert" {
  name_prefix       = "letfdemo-cert-"
  certificate_body  = "${var.demo_env_cert_body}"
  certificate_chain = "${var.demo_env_cert_chain}"
  private_key       = "${var.demo_env_cert_privkey}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name = "letfdemo-elb-www"
  
  subnets         = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.nginx.*.id}"]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.elb_cert.arn}"

  }

  tags {
    Name    = "letfdemo-elb"
    Purpose = "letfdemo"
  }
}

# ------------------------------------------
#  AWS : Instance (nginx) related config
# ------------------------------------------

# Our Nginx security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "nginx-sg" {
  name        = "letfdemo-nginx-sg"
  description = "Security group for nginx"
  vpc_id      = "${aws_vpc.demovpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.20.100.0/24"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "letfdemo-nginx-sg"
    Purpose = "letfdemo"
  }
}

# ----------------------------------------------------
# Terraform currently only supports importing an existing 
# key pair, not creating a new key pair
# ----------------------------------------------------
resource "tls_private_key" "nginx-provisioner" {
    algorithm   = "RSA"
}

resource "aws_key_pair" "nginx-provisioning" {
  key_name   = "letfdemo-provisioning-key"
  public_key = "${tls_private_key.nginx-provisioner.public_key_openssh}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "nginx" {

  count = "${var.demo_env_nginx_count}"
  connection {
    # The default username for our AMI, and use our on the fly created 
    # private key to do the initial bootstrapping (install of nginx)
    user        = "ubuntu"
    private_key = "${tls_private_key.nginx-provisioner.private_key_pem}"
  }

  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.nginx-provisioning.id}"
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]
  # We're going to launch into the same single (public) subnet as our ELB. 
  # In a production environment it's more common to have a separate 
  # private subnet for backend instances.
  subnet_id     = "${aws_subnet.public.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo sed -i 's/nginx\\!/nginx - instance ${count.index + 1}/g' /var/www/html/index.nginx-debian.html",
      "sudo systemctl start nginx",
    ]
  }

  tags {
    Name    = "letfdemo-nginx${count.index + 1}"
    Purpose = "letfdemo"
  }  
}