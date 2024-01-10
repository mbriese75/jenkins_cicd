resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  
  tags = {
    Name = var.name_tag,
  }
  
  key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}

#Create security group 
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Open ports 22"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Incoming SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["69.42.6.44/32" , "192.168.1.175/32" , "98.42.124.215/32]
  }
}

resource "aws_key_pair" "autodeploy" {
  key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}
