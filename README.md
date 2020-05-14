# Nginx / Apache servers with Application Load Balancer

This small project contains the necessary terraform scripts to build a micro infrastructure with 2 http servers and 1 application load balancer on AWS Cloud.

## Requirements

The entire configuration is made using exclusively terraform.<br/>
The project was built and tested using version `v0.12.20` of the tool.<br/><br/>
Available in: https://releases.hashicorp.com/terraform/0.12.20/

## Resources

Although it is simple, this project contains concepts of cybersecurity.<br/><br/>
Below is a list of resources and doc:

* [Basic network](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/docs/basic_network.md) (VPC, subnets, gateways and more)
* [Security resources](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/docs/security_resources.md) (key pairs and security groups)
* [Application resources](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/docs/application_resources.md) (ec2 instances)
* [Load balancer resources](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/docs/load_balancer.md) (Alb, target groups, listeners and more)

This is a simple diagram of this resources:<br/><br/>

<img src="https://github.com/LucasFonseca93/terraform-alb-sample/raw/master/docs/diagram.png" width="550">

## How to run
Suggestion on how to run the scripts:
```
terraform init
terraform validate # optional
terraform plan # optional
terraform apply 
```

## Outputs

The script generates a series of outputs containing:

* created vpc id
* public bastion id and ip
* private id and ip of the nginx instance
* apache instance id and private ip
* loadbalancer dns address

Sample:
```
Outputs:

apache = ID: i-054ebd57cc16b55b5 Private IP: 172.18.93.158
bastion = ID: i-0651fec28cb9497f1 Public IP: 3.209.118.216
lb_address = test-lucas-fonseca-app-lb-703623986.us-east-1.elb.amazonaws.com
nginx = ID: i-074ebd1f64384d79f Private IP: 172.18.90.106
vpc_id = vpc-06d7913415e9859f0
```