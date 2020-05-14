
variable "aws_region" {
  description = "EC2 Region for the VPC"
  default = "us-east-1"
}

variable "basic_data" {
  description = "Basic data for project"
  default = {
    name_prefix = "test-lucas-fonseca"
    squad = "devops"
    owner = "Lucas Fonseca"
  }
}

variable "vpc_data" {
  description = "CIDR for the whole VPC"
  default = {
    cidr = "172.18.80.0/20"
  }
}

variable "public_subnet_data" {
  description = "CIDR for public subnets"
  default = {
    cidr = [
      "172.18.80.0/23",
      "172.18.82.0/23",
      "172.18.84.0/23"
    ]
    zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]
  }
}

variable "private_subnet_data" {
  description = "CIDR for private subnets"
  default = {
    cidr = [
      "172.18.88.0/22",
      "172.18.92.0/22"
    ]
    zones = [
      "us-east-1a",
      "us-east-1b"
    ]
  }
}

variable "key" {
  description = "key pair names"
  default = {
    key_bastion = "bastion-key-pair"
    key_ec2 = "ec2-key-pair"
  }
}

variable "ec2_data" {
  description = "Basic ami's for use on ec2 instances"
  default = {
    ami = {
      bastion = "ami-0323c3dd2da7fb37d" # amazon linux 2
      nginx = "ami-039a49e70ea773ffc" # ubuntu 16.04
      apache = "ami-039a49e70ea773ffc" # ubuntu 16.04
    }
    size = {
      bastion = "t2.micro"
      nginx = "t2.micro"
      apache = "t2.micro"
    }
  }
}
