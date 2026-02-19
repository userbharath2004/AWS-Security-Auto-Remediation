provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "s3-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3-remediation-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      }
    ]
  })
}

resource "aws_lambda_function" "s3_remediate" {
  function_name = "s3-public-remediator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "remediate.lambda_handler"
  runtime       = "python3.9"

  filename         = "lambda/function.zip"
  source_code_hash = filebase64sha256("lambda/function.zip")
}

resource "aws_cloudwatch_event_rule" "scheduled_scan" {
  name                = "s3-scan-schedule"
  schedule_expression = "rate(5 minutes)"
}


resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_scan.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.s3_remediate.arn
}


resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_remediate.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_scan.arn
}