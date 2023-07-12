variable "aws_account_id" {
  default = "936066658209"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_id" {
  default = "vpc-0cf5db5184c53cfd2"
}
variable "subnets" {
  type = list(string)
  default = [
    "subnet-0732ea16875c7155d",
    "subnet-0d40ef6434cf878e8",
    "subnet-0d92a749c7babdbf2",
    "subnet-0920b3572a0a5de72",
  ]
}

variable "load_balancer_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:936066658209:loadbalancer/app/flask-app-demo/ec5b4b7c66c02ca7"
}

environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.ecr_repo.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = aws_ecs_cluster.flask_app_demo.name
    }
    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = aws_ecs_service.flask_app_demo.name
    }
    environment_variable {
      name  = "ECS_TASK_DEFINITION"
      value = aws_ecs_task_definition.flask_app_demo.family
    }
