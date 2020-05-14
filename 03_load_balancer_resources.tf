
# -----------------------------------------------------------------------------------------------
# s3
# 1 - creates a bucket policy for logs
# 2 - creates a s3 private bucket for lb logs
# -----------------------------------------------------------------------------------------------
data "aws_elb_service_account" "main" {}

data "template_file" "s3_policy_template" {
  template = file("${path.module}/policy/logs_bucket.json.tpl")
  vars = {
    s3_arn = "arn:aws:s3:::${var.basic_data["name_prefix"]}-lb-log/AWSLogs/*"
    aws_acc = "${data.aws_elb_service_account.main.arn}"
  }
}

resource "aws_s3_bucket" "lb_log_bucket" {
  bucket = "${var.basic_data["name_prefix"]}-lb-log"
  acl = "private"
  policy = data.template_file.s3_policy_template.rendered
  force_destroy = true
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-lb-log"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
      data.template_file.s3_policy_template
  ]
}

# -----------------------------------------------------------------------------------------------
# Load balancer
# 1 - creates a application load balancer
# 2 - creates a http target group for applications
# 3 - creates a http listener
# 4 - creates a attachment between instances and target group
# -----------------------------------------------------------------------------------------------
resource "aws_alb" "app_lb" {
  name = "${var.basic_data["name_prefix"]}-app-lb"
  subnets = [
    element(aws_subnet.main_vpc_public_subnets.*.id, 0),
    element(aws_subnet.main_vpc_public_subnets.*.id, 1),
    element(aws_subnet.main_vpc_public_subnets.*.id, 2)
  ]
  security_groups = [
    aws_security_group.lb_sg.id
  ]
  internal = false
  ip_address_type = "ipv4"
  idle_timeout = 3600
  access_logs {
    bucket = aws_s3_bucket.lb_log_bucket.bucket
    enabled = true
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-app-lb"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_subnet.main_vpc_public_subnets,
    aws_security_group.lb_sg,
    aws_s3_bucket.lb_log_bucket
  ]
}

resource "aws_alb_target_group" "http_tg" {
  name = "${var.basic_data["name_prefix"]}-http-tg"
  port = "80"
  target_type = "instance"
  protocol = "HTTP"
  vpc_id = aws_vpc.main_vpc.id
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 5
    interval = 10
    path = "/"
    port = "80"
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-http-tg"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc
  ]
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.app_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.http_tg.arn
    type = "forward"
  }
  depends_on = [
    aws_alb.app_lb,
    aws_alb_target_group.http_tg
  ]
}

resource "aws_alb_target_group_attachment" "lb_http_nginx_attach" {
  target_group_arn = aws_alb_target_group.http_tg.arn
  target_id = aws_instance.nginx.id
  port = 80
  depends_on = [
    aws_alb_target_group.http_tg,
    aws_instance.nginx
  ]
}

resource "aws_alb_target_group_attachment" "lb_http_apache_attach" {
  target_group_arn = aws_alb_target_group.http_tg.arn
  target_id = aws_instance.apache.id
  port = 80
  depends_on = [
    aws_alb_target_group.http_tg,
    aws_instance.apache
  ]
}

# -----------------------------------------------------------------------------------------------
# Outputs section
# -----------------------------------------------------------------------------------------------
output "lb_address" {
  description = "The DNS name of the load balancer."
  value       = aws_alb.app_lb.dns_name
}