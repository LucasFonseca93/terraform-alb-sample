# Load balancer resources

* [source file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/03_load_balancer_resources.tf)
* [variables file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/variables.tf)

> The documentation described below is based on the variables file.

This session is designed to create the necessary resources for load balancing between http servers.

An Application Load Balancer and an s3 bucket will be created to store your access logs.

> The load balancer will be created using the 3 public subnets of the VPC.

An http target group and an http listener will be created which will then be linked to http instances.