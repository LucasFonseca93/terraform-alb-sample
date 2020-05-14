
# -----------------------------------------------------------------------------------------------
# Key pairs
# 1 - creates a key pair for access bastion
# 2 - creates a key pair for access ec2 private instances
# -----------------------------------------------------------------------------------------------
resource "aws_key_pair" "key_bastion" {
  key_name   = var.key["key_bastion"]
  public_key = file("${path.module}/keys/bastion/bastion.pub.pem")
}

resource "aws_key_pair" "key_ec2" {
  key_name   = var.key["key_ec2"]
  public_key = file("${path.module}/keys/ec2/ec2.pub.pem")
}

# -----------------------------------------------------------------------------------------------
# Security groups
# 1 - creates a sg for bastion
# 2 - creates a sg for load balancer
# 2 - creates a sg for ec2 private instances
# -----------------------------------------------------------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name = "${var.basic_data["name_prefix"]}-bastion-sg"
  description = "Allow incoming SSH connections."
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    description = "Allow SSH to vpc network"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    description = "Allow all outcome access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-bastion-sg"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc
  ]
}

resource "aws_security_group" "lb_sg" {
  name = "${var.basic_data["name_prefix"]}-lb-sg"
  description = "Allow incoming SSH and HTTPconnections."
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    description = "Allow HTTP to all"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    description = "Allow all outcome access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-lb-sg"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name = "${var.basic_data["name_prefix"]}-ec2-sg"
  description = "Allow incoming SSH and HTTP connections."
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    description = "Allow SSH to bastion instance"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }
  ingress {
    description = "Allow HTTP requests from the LB security group"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      aws_security_group.bastion_sg.id,
      aws_security_group.lb_sg.id
    ]
  }
  egress {
    description = "Allow all outcome access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-ec2-sg"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc,
    aws_security_group.bastion_sg,
    aws_security_group.lb_sg
  ]
}
