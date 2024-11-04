
resource "aws_ami_from_instance" "my_ami" {
  name               = var.ami_name  # Unique name for the AMI
  source_instance_id = var.instance_id               # Replace with your specific instance ID
  description        = "An AMI created from instance id"  # Replace with relevant description

}

# Create a null resource to introduce a sleep
resource "null_resource" "wait" {
  depends_on = [aws_ami_from_instance.my_ami]

  provisioner "local-exec" {
    command = "sleep 150"  # Sleep for 30 seconds; adjust as needed
  }
}

# Launch multiple instances using the specified AMI ID
resource "aws_instance" "my_instances" {
  ami           = aws_ami_from_instance.my_ami.id      # Use the AMI ID from the variable
  instance_type = "t2.micro"                              # Adjust the instance type as needed
  count         = 3                                   # Creates 10 instances

  tags = {
    Name = "TF"  # Name each instance uniquely
  }
}




