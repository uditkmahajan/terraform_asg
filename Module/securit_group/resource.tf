resource "aws_security_group" "security_group" {
  vpc_id= "${var.vpc-id}"
  name = "udit-security-group"
  ingress {
    from_port   = 0
    to_port     = 0                # ipv4 konse port se request bhej raha h sab ane do
    protocol    = "80"             # ipv4 ki request koi se bhi protocol ki ho ane do
    cidr_blocks = ["0.0.0.0/0"]    # ipv4 ka koi sa bhi address ho chalega andar ane do
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "udit-security"
  }
}