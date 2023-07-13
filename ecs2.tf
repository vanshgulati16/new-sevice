resource "aws_ecs_task_definition" "flask_app_demo-v2" {
  family                   = "flask-app-demo-v2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.task_role-2.arn
  container_definitions = <<DEFINITION
[
  {
    "name": "flask-app-demo-v2",
    "image": "${aws_ecr_repository.ecr_repo.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "cpu": 256, 
    "memory": 512
  }
]
DEFINITION
  execution_role_arn = aws_iam_role.task_definition_role-2.arn
}
resource "aws_ecs_service" "flask_app_demo-v2" {
  name            = "flask-app-demo-v2"
  cluster         = "arn:aws:ecs:us-east-1:936066658209:cluster/flask-app-demo"
  task_definition = aws_ecs_task_definition.flask_app_demo-v2.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.flask_app_demo-v2.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.flask_app_demo-v2.arn
    container_name   = "flask-app-demo-v2"
    container_port   = 5000
  }
}
resource "aws_security_group" "flask_app_demo-v2" {
  name        = "flask-app-demo-v2"
  description = "Allow inbound traffic to flask app"
  vpc_id      = var.vpc_id
  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_lb_target_group" "flask_app_demo-v2" {
  name        = "flask-app-demo-v2"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "flask-app-demo-v2"
  }
}

resource "aws_lb_listener" "flask_app_demo-v2" {
  load_balancer_arn = var.load_balancer_arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_app_demo-v2.arn
  }
}
resource "aws_lb_listener_rule" "flask_app_demo-v2" {
  listener_arn = aws_lb_listener.flask_app_demo-v2.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_app_demo-v2.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
resource "aws_iam_role" "task_definition_role-2" {
  name = "flask_demo_task_definition-2a"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "task_definition_policy-2" {
  name   = "flask_demo_task_definition_policy-2"
  role   = aws_iam_role.task_definition_role-2.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "task_role-2" {
  name               = "flask-app-demo-task-role-2a"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "task_role_policy-2" {
  name   = "flask-app-demo-task-role-policy-2"
  role   = aws_iam_role.task_role-2.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:CreateTargetGroup",
      "Resource": "*"
    }
  ]
}
EOF
}






