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
variable "image_repo_name" {
  default = "flask-demo-application"
}

variable "image_tag" {
  default = "latest"
}
variable "image_repo_url" {
  default = "936066658209.dkr.ecr.us-east-1.amazonaws.com/flask-demo-application"
}

variable "load_balancer_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:936066658209:loadbalancer/app/flask-app-demo/ec5b4b7c66c02ca7"
}