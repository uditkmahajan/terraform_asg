resource "aws_instance" "ec2" {
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key-name}"
  availability_zone = "${var.az}"
  associate_public_ip_address = "${var.public-ip}"
  vpc_security_group_ids = "${var.sg}"
  tags = {
    Name = "${var.ec2-name}"
  }
}