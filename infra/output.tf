
output "ami_id" {
  value = aws_ami_from_instance.my_ami.id
}