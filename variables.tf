variable "aws_account_id" {
  default = "936066658209"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_id" {
  default = "vpc-048b42853bc93e76b"
}
variable "subnets" {
  type = list(string)
  default = [
    "subnet-00060d748fc5b2101",
    "subnet-069b9389004c2f5e2",
    "subnet-0f3b9c9c433adf52e",
    "subnet-055f9c54c38aa10b9",
  ]
}
variable "image_repo_name" {
  default = "flask-demo-application-v2"
}

variable "image_tag" {
  default = "latest"
}
variable "image_repo_url" {
  default = "936066658209.dkr.ecr.us-east-1.amazonaws.com/flask-demo-application-v2"
}
variable "github_repo_owner" {
  default = "vanshgulati16"
}
variable "github_repo_name" {
  default = "terraform-ecs-codepipeline-demo-v2"
}
variable "github_branch" {
  default = "main"
}