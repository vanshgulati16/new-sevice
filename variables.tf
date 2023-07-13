variable "aws_account_id" {
  default = "936066658209"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_id" {
  default = "vpc-0ddfd87915d336a43"
}
variable "subnets" {
  type = list(string)
  default = [
    "subnet-0c56b532e4c93bdf8",
    "subnet-0acb86a64ce709d5e",
    "subnet-01633d8d54a2c867a",
    "subnet-0585471c71c8a0e39",
  ]
}

variable "load_balancer_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:936066658209:loadbalancer/app/flask-app-demo/022efa8662eb2dc1"
}

variable "load_balancer_listener_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:936066658209:listener/app/flask-app-demo/022efa8662eb2dc1/9c60191c8da39adb"
}


