provider "aws" {
 
}
resource "aws_ecs_cluster" "django-cluster" {
  name = "django-cluster"
}

resource "aws_ecr_repository" "django-app" {
  name = "django-app"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "my-subnet-${count.index + 1}"
  }
}
resource "aws_security_group" "ecs" {
  name_prefix = "ecs-"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_cloudwatch_log_group" "django_app_logs" {
  name = "/ecs/my-django-app"

  tags = {
    Environment = "Production"
    AppName     = "my-django-app"
  }
}


resource "aws_ecs_task_definition" "django_app" {
  family                   = "django-app"
  container_definitions    = <<DEFINITION
[
  {
    "name": "django-app",
    "image": "168130825968.dkr.ecr.us-east-1.amazonaws.com/django-app/my-django-app",
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ],
    "environment": [
      {
        "name": "DJANGO_SETTINGS_MODULE",
        "value": "DJANGO.settings.prod"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":"/ecs/my-django-app",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = 512
  cpu                      = 256
}
