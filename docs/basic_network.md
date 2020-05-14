### Basic network resources

* [source file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/00_basic_network.tf)
* [variables file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/variables.tf)

> The documentation described below is based on the variables file.

This terraform script contains the necessary modules for creating the primary structure of a network on AWS (the VPC).<br/>
For this scenario the CIDR defined for the vpc was `172.18.80.0/20` and AZ was `us-east-1`

| Scope | cidr | zone |
| ----- | ---- | ---- |
| private | 172.18.88.0/22 | us-east-1a |
| private | 172.18.92.0/22 | us-east-1b |
| public | 172.18.80.0/22 | us-east-1a |
| public | 172.18.82.0/22 | us-east-1b |
| public | 172.18.84.0/22 | us-east-1c |


Temos apenas duas tabelas de rotas bem simples:

| Scope | cidr | destinaton |
| ----- | ---- | ---------- |
| private | 0.0.0.0/0 | nat gateway |
| public | 0.0.0.0/0 | internet gateway |