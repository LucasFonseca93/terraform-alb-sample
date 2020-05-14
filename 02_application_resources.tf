
# -----------------------------------------------------------------------------------------------
# Bastion
# 1 - creates a bastion instance
# 2 - creates a elasticip for bastion
# -----------------------------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami               = lookup(var.ec2_data["ami"], "bastion")
  availability_zone = element(var.public_subnet_data["zones"], 0)
  instance_type     = lookup(var.ec2_data["size"], "bastion")
  key_name          = aws_key_pair.key_bastion.key_name
  subnet_id         = element(aws_subnet.main_vpc_public_subnets.*.id, 0)
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]
  associate_public_ip_address = true
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-bastion"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_key_pair.key_bastion,
    aws_subnet.main_vpc_public_subnets
  ]
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  vpc      = true
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-bastion-eip"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_instance.bastion
  ]
}

# -----------------------------------------------------------------------------------------------
# Nginx
# 1 - creates a ec2 instance with nginx
# -----------------------------------------------------------------------------------------------
resource "aws_instance" "nginx" {
  ami               = lookup(var.ec2_data["ami"], "nginx")
  availability_zone = element(var.private_subnet_data["zones"], 0)
  instance_type     = lookup(var.ec2_data["size"], "nginx")
  key_name          = aws_key_pair.key_ec2.key_name
  subnet_id         = element(aws_subnet.main_vpc_private_subnets.*.id, 0)
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]
  connection {
    type = "ssh"
    host = self.private_ip
    user = "ubuntu"
    private_key = file("${path.module}/keys/ec2/ec2.key.pem")
    # uses bastion ssh tunel
    bastion_host = aws_eip.bastion_eip.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = file("${path.module}/keys/bastion/bastion.key.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-nginx-instance"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_key_pair.key_ec2,
    aws_subnet.main_vpc_private_subnets,
    aws_instance.bastion,
    aws_eip.bastion_eip
  ]
}

# -----------------------------------------------------------------------------------------------
# Apache
# 1 - creates a ec2 instance with apache
# -----------------------------------------------------------------------------------------------
resource "aws_instance" "apache" {
  ami               = lookup(var.ec2_data["ami"], "apache")
  availability_zone = element(var.private_subnet_data["zones"], 1)
  instance_type     = lookup(var.ec2_data["size"], "apache")
  key_name          = aws_key_pair.key_ec2.key_name
  subnet_id         = element(aws_subnet.main_vpc_private_subnets.*.id, 1)
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]
  connection {
    type = "ssh"
    host = self.private_ip
    user = "ubuntu"
    private_key = file("${path.module}/keys/ec2/ec2.key.pem")
    # uses bastion ssh tunel
    bastion_host = aws_eip.bastion_eip.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = file("${path.module}/keys/bastion/bastion.key.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install apache2",
      "sudo service apache2 start",
    ]
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-apache-instance"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_key_pair.key_ec2,
    aws_subnet.main_vpc_private_subnets,
    aws_instance.bastion,
    aws_eip.bastion_eip
  ]
}

# -----------------------------------------------------------------------------------------------
# Outputs section
# -----------------------------------------------------------------------------------------------
output "bastion" {
  value = "ID: ${aws_instance.bastion.id} Public IP: ${aws_eip.bastion_eip.public_ip}"
}

output "nginx" {
  value = "ID: ${aws_instance.nginx.id} Private IP: ${aws_instance.nginx.private_ip}"
}

output "apache" {
  value = "ID: ${aws_instance.apache.id} Private IP: ${aws_instance.apache.private_ip}"
}
