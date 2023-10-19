resource "aws_cognito_user_pool" "pool" {
  name = "hook-user-pool"
  # Add user pool configuration here
}

# Define IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "hook-lambda-execution-role"
  # Define IAM policies and permissions as needed
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create Lambda Functions
resource "aws_lambda_function" "jira_lambda" {
  filename      = "lambdas/jira_lambda/jira_lambda.zip"
  function_name = "jiraLambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda.handler"
  runtime       = "python3.8"
  # ...
}

# resource "aws_lambda_function" "slack_lambda" {
#   filename      = "lambdas/slack_lambda/slack_lambda.zip"
#   function_name = "slackLambda"
#   role          = aws_iam_role.lambda_execution_role.arn
#   handler       = "lambda.handler"
#   runtime       = "python3.8"
#   # ...
# }

# Define API Gateway
resource "aws_api_gateway_rest_api" "hook" {
  name = "hook-api"
}

# Define API Gateway Authorizer for JWT validation
resource "aws_api_gateway_authorizer" "jwt_authorizer" {
  name          = "jwt-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.hook.id
  identity_source = "method.request.header.Authorization"
  type          = "JWT"
  authorizer_credentials = aws_iam_role.lambda_execution_role.name
  # Define token validation settings
  # ...
}

# Define /jira endpoint
resource "aws_api_gateway_resource" "jira_resource" {
  rest_api_id = aws_api_gateway_rest_api.hook.id
  parent_id   = aws_api_gateway_rest_api.hook.root_resource_id
  path_part   = "jira"
}

resource "aws_api_gateway_method" "jira_method" {
  rest_api_id   = aws_api_gateway_rest_api.hook.id
  resource_id   = aws_api_gateway_resource.jira_resource.id
  http_method   = "POST"
  authorization = aws_api_gateway_authorizer.jwt_authorizer.id
}

# Define /slack endpoint (similar to /jira)

# Create API Gateway Integration (associate with Lambda functions)
resource "aws_api_gateway_integration" "jira_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hook.id
  resource_id             = aws_api_gateway_resource.jira_resource.id
  http_method             = aws_api_gateway_method.jira_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.jira_lambda.invoke_arn
}

# Define /slack integration (similar to /jira)

# Create API Gateway Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.hook.id
  stage_name  = var.deployment_stage
}

# Configure CORS if needed
