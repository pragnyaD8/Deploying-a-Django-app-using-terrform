provider "aws" {
  region     = "us-east-1"
  access_key = "AKIASOJLAZ3YPHOOK43M"
  secret_key = "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"
}
resource "aws_instance" "myec2"{
    ami="ami-0aa7d40eeae50c9a9"
    instance_type=var.instance_type
}
resource "aws_security_group" "lb_sg" {
  name_prefix = "example_security_group"
  description = "Example Security Group"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "example_security_group"
  }
}
resource "aws_lb_target_group" "tg" {
  name_prefix = "tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    path = "/"
  }
}
resource "aws_lb" "lb" {
  name = "my-lb"
  internal = false
  load_balancer_type = "application"
  subnets= ["subnet-0bb2d772f21649600", "subnet-05768d6344c0037e2"]
  security_groups = [aws_security_group.lb_sg.id]

  tags = {
    Name = "my-lb"
  }


  depends_on = [aws_lb_target_group.tg]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

