resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id = "${aws_subnet.public_subnets.id}"
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
 
  tags = {
    Name = var.name_tag,
  }
  
  key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}

resource "aws_key_pair" "autodeploy" {
  key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

#Create security group 
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Open ports 22"
  vpc_id = "${aws_vpc.main.id}"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["69.42.6.44/32" , "98.42.124.215/32", "192.168.1.175/32" ]
  }
# Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create the EBS volume
resource "aws_ebs_volume" "st1" {
 availability_zone = aws_instance.public_instance.availability_zone
 size = 5
 tags = {
   Name = " My Volume"
  }
}

#attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "ebs" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.st1.id
  instance_id = aws_instance.public_instance.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "${var.vpc_name}-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name} IG"
  }
}

resource "aws_subnet" "public_subnets" {
     vpc_id = aws_vpc.main.id
     cidr_block = "10.10.1.0/24"
      map_public_ip_on_launch = true
 
     tags = {
         Name = "my_public_subnet"
       } 
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.10.0/24"

  tags = {
    Name = "my_private_subnet"
  }
}


resource "aws_route_table" "subnets" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
    subnet_id = "${aws_subnet.public_subnets.id}"
    route_table_id = "${aws_route_table.subnets.id}"
}


resource "aws_route_table_association" "private_subnet_asso" {
  subnet_id = "${aws_subnet.private_subnets.id}"
  route_table_id = "${aws_route_table.subnets.id}"
}


resource "aws_s3_bucket" "my_bucket" {
  bucket = "mybucket3445345656457676878687867867867"
  acl    = "private"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }
}



