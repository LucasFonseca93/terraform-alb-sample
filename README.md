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

<div style="text-align:center">
<img src="https://github.com/LucasFonseca93/terraform-alb-sample/raw/master/docs/diagram.png" width="550">
</div>

## How to run
First of all initialize the necessary terraform plugins to run the scripts:
```
terraform init
```

After that it is possible to check if the scripts do not contain any type of error:
```
terraform validate
```

See what will be built into your aws account by running the following command:
```
terraform plan
```

Just run the apply command to create the resources:
```
terraform apply
```