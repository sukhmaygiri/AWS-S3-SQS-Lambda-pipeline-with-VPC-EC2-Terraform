resource "aws_instance" "demo" {

  ami           = "ami-04a64102b8022e4f3"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  associate_public_ip_address = false

  tags = {
    Name = "terraform-ec2"
  }
}
