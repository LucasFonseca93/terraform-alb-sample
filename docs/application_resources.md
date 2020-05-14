# Application resources

* [source file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/02_application_resources.tf)
* [variables file](https://github.com/LucasFonseca93/terraform-alb-sample/blob/master/variables.tf)

> The documentation described below is based on the variables file.

This resource section is intended to create the ec2 instances used by the micro infrastructure.

> It is worth mentioning that because they are small instances (t2.micro) the up and running process can be a little slow.

Table of created resources:

| resource | subnet | image | key pair |
| -------- | ------ | ----- | -------- |
| bastion | public | amzon linux 2 | bastion key |
| nginx | private | ubuntu 16.04 | ec2 key |
| apache | private | ubuntu 16.04 | ec2 key |

### Configuration of http servers

For the simple task of just uploading a nginx and an apache on each of the http servers, complex structures are not necessary.

I chose inside terraform to open a `ssh tunnel` between bastion and private instance and execute a short list of bash commands for installing packages.

> Due to the reduced size and processing capacity of the instances, this configuration step may take a few minutes

#### Nginx configuration 

```
sudo apt-get -y update
sudo apt-get -y install nginx
sudo service nginx start
```

#### Apache configuration 

```
sudo apt-get -y update
sudo apt-get -y install apache2
sudo service apache2 start
```