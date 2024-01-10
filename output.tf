output "public_ip" {
 value       = aws_instance.public_instance.public_ip
 description = "Public IP Address of EC2 instance"
}

output "instance_id" {
 value       = aws_instance.public_instance.id
 description = "Instance ID"
}

output "volume_id" {
  value = aws_ebs_volume.st1.id
}

output "attachment_id" {
  value = aws_volume_attachment.ebs.id
}
