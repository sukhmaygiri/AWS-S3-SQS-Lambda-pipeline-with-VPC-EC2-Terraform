resource "aws_lambda_function" "demo" {

  function_name = "s3-sqs-lambda"
  role          = aws_iam_role.lambda_role.arn

  handler = "function.lambda_handler"
  runtime = "python3.9"

  filename         = "lambda/function.zip"
  source_code_hash = filebase64sha256("lambda/function.zip")

  timeout = 10
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {

  event_source_arn = aws_sqs_queue.demo.arn
  function_name    = aws_lambda_function.demo.arn

  batch_size = 1
}
