
resource "aws_iam_role" "amplify_role" {
  name = "amplify_deploy_terraform_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "amplify.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy" "amplify_role_policy" {
  name = "amplify_iam_role_policy"
  role = aws_iam_role.amplify_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("${path.cwd}/modules/frontend/amplify_role_policies.json")
}


resource "aws_amplify_app" "frontend" {
  name = "${var.project_name}-${var.environment}"
  repository = var.github_repository
  access_token= var.github_token_for_frontend

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  enable_auto_branch_creation = true
  enable_branch_auto_build = true
  enable_branch_auto_deletion = true
  platform = "WEB"

  auto_branch_creation_config {
    enable_pull_request_preview = true
    environment_variables = {
      APP_ENVIRONMENT = "develop"
    }
  }

  iam_service_role_arn = aws_iam_role.amplify_role.arn

  #Comment this on the first run, trigger a build of your branch, This will added automatically on the console after deployment. Add it here to ensure your subsequent terraform runs don't break your amplify deployment.
  custom_rule {
    source = "/<*>"
    status = "200"
    target = "https://<*>.cloudfront.net/<*>" 
  }

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"  
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# map git branches to amplify
#- - - - - - - - - - - - - - -- - - -- - - - - -- - - - - - -
resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "develop"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "DEVELOPMENT"

  environment_variables = {
    APP_ENVIRONMENT = "develop"
  }
}

resource "aws_amplify_branch" "uat" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "uat"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "PRODUCTION"

  environment_variables = {
    APP_ENVIRONMENT = "uat"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "PRODUCTION"

  environment_variables = {
    APP_ENVIRONMENT = "main"
  }
}

#- - - - - - - - - - - - - - -- - - -- - - - - -- - - - - - -

resource "aws_amplify_domain_association" "develop" {
  app_id      = aws_amplify_app.frontend.id
  domain_name = "staging.${var.domain}"

  sub_domain {
    branch_name = aws_amplify_branch.develop.branch_name
    prefix      = ""
  }

  sub_domain {
    branch_name = aws_amplify_branch.develop.branch_name
    prefix      = "www"
  }
}


resource "aws_amplify_domain_association" "main" {
  app_id      = aws_amplify_app.frontend.id
  domain_name = "${var.domain}"

  # https://---.co
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # https://www.---.co
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
}