output "backend_public_ip" {
  description = "Public IP of backend instance"
  value       = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  description = "Public IP of frontend instance"
  value       = aws_instance.frontend.public_ip
}

output "backend_public_dns" {
  description = "Public DNS of backend instance"
  value       = aws_instance.backend.public_dns
}

output "ssh_command_backend" {
  description = "SSH command for backend instance"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.backend.public_ip}"
}

output "ssh_command_frontend" {
  description = "SSH command for frontend instance"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.frontend.public_ip}"
}