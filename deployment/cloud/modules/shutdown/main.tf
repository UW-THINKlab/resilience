// lambda function

// code 

data "archive_file" "shutdown_lambda_code" {
  type         = "zip"
  source_file  = "${path.module}/shutdown.py"
  output_path  = "${path.module}/shutdown_lambda.zip"
}

// function execution role

resource "aws_iam_role" "shutdown_lambda_role" {
  name = "support_sphere_shutdown_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "shutdown_lambda_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:SetDesiredCapacity"
          ],
          Resource = var.asg_arn
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "*"
        }
      ]
    })
  
  }
  
}

// function

resource "aws_lambda_function" "shutdown_lambda" {
  filename      = "shutdown_lambda.zip"
  function_name = "support_sphere_shutdown_lambda"
  role          = aws_iam_role.shutdown_lambda_role.arn
  handler       = "shutdown.lambda_handler"

  source_code_hash = data.archive_file.shutdown_lambda_code.output_base64sha256

  runtime       = "python3.8"
  timeout       = 60

  environment {
    variables = {
      ASG_NAME = var.asg_name
    }
  }
}

// eventbridge rule

resource "aws_cloudwatch_event_rule" "shutdown_lambda_trigger" {
  name        = "support_sphere_shutdown_trigger"
  description = "Shutdown the server every weekday at 1AM UTC (6PM PDT/5PM PST)"
  schedule_expression = "cron(0 1 * * MON-FRI *)"
}

// eventbridge target

resource "aws_cloudwatch_event_target" "shutdown_lambda_target" {
  rule      = aws_cloudwatch_event_rule.shutdown_lambda_trigger.name
  target_id = "support_sphere_shutdown_target_lambda"
  arn       = aws_lambda_function.shutdown_lambda.arn
}


// eventbridge permission to invoke lambda

resource "aws_lambda_permission" "shutdown_lambda_trigger_invoke_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shutdown_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_lambda_trigger.arn
}