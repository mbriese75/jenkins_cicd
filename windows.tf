resource "aws_instance" "windows-server" {
     ami = var.win_ami
     instance_type = var.instance_type
     vpc_security_group_ids    = [aws_security_group.windows.id]
     key_name= "windows_deploy"
     user_data = <<EOF
     <powershell>
     #Copy the output of the command get-process in running.txt
     #Set path 
     $path = "$env:UserProfile\Desktop\running.txt"
     #if file exist remove it and create it again
     if (Test-Path $path) {
          Remove-Item $path
          Get-Process | Out-File -FilePath $path
     } else {
          Get-Process | Out-File -FilePath $path
     }
</powershell>
 EOF

 tags = {
    Name        = "windows"
  }
}

#Create security group 
resource "aws_security_group" "windows" {
  #Allow incoming TCP requests on port 22 from any IP
  name        = "jenkins2"
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = ["69.42.6.44/32" , "98.51.2.169/32", "71.198.26.65/32" ]
  }
# Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "windows_deploy"  
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename = "/var/jenkins_home/.ssh/win.pem"
  content  = tls_private_key.key_pair.private_key_pem 
}
