resource "aws_codepipeline" "codepipeline" {
  name     = "flask_demo_pipeline-v2"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
    
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.example.arn
        FullRepositoryId = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName       = var.github_branch
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.flask_app.name
      }
    }
  }
}
resource "aws_codestarconnections_connection" "example" {
  name          = "flask-demo-connection-v2"
  provider_type = "GitHub"
}
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "vansh-flask-demo-codepipeline-bucket-v2"
}
# resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id
#   acl    = "private"
# }
resource "aws_iam_role" "codepipeline_role" {
  name = "flask_demo_codepipeline_role-v2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TrustPolicyStatementThatAllowsEC2ServiceToAssumeTheAttachedRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "flask_demo_codepipeline_policy-v2"
  role = aws_iam_role.codepipeline_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.example.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStacks",
        "kms:GenerateDataKey",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_codebuild_project" "flask_app" {
  name          = "flask-app-demo-v2"
  description   = "Builds a flask application version 2"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "5"
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
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
      value = var.image_repo_name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }
    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = "flask-app-demo"
    }
    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = aws_ecs_service.flask_app_demo-v2.name
    }
    environment_variable {
      name  = "ECS_TASK_DEFINITION"
      value = aws_ecs_task_definition.flask_app_demo-v2.family
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
resource "aws_iam_role" "codebuild_role" {
  name = "flask_demo_codebuild_role-v2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "TrustPolicyStatementThatAllowsEC2ServiceToAssumeTheAttachedRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "flask_demo_codebuild_policy-v2"
  role = aws_iam_role.codebuild_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.bucket}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": [
        "*"
      ],
        "Effect": "Allow"
    },
    {
      "Action": [
        "ecs:UpdateService",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": [
        "*"
      ],
        "Effect": "Allow"
    }
  ]
}
EOF
}
data "aws_kms_alias" "s3kmskey" {
  name = "alias/flask_app_v2_s3kmskey"
}