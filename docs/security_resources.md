### Security resources

* [source file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/01_security_resources.tf)
* [variables file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/variables.tf)

> The documentation described below is based on the variables file.

For greater security, sensitive instances must be in private subnets to be susceptible to a reduced range of attacks. 

* It is natural and necessary that these instances can be accessed via ssh to execute configurations so we add a bastion to a public subnet, to access the private subnet instances through it.

* These instances must be accessible via the load balancer too

Description of the bastion security group:

| type | from | port | protocol |
| ---- | ---- | ---- | -------- |
| ingress | 0.0.0.0/0 | 22 | TCP/SSH |
| egress | all trafic | all trafic | all trafic |

> The ideal is to release bastion access only to the company's VPN

Description of the load balancer security group:

| type | from | port | protocol |
| ---- | ---- | ---- | -------- |
| ingress | 0.0.0.0/0 | 80 | TCP/HTTP |
| egress | all trafic | all trafic | all trafic |

Description of the ec2 private instances security group:

| type | from | port | protocol |
| ---- | ---- | ---- | -------- |
| ingress | load balancer security group  | 80 | TCP/HTTP |
| ingress | bastion security group | 22 | TCP/SSH |
| egress | all trafic | all trafic | all trafic |