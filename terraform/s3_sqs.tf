resource "aws_sqs_queue_policy" "allow_s3" {

  queue_url = aws_sqs_queue.demo.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.demo.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.demo.arn
          }
        }
      }
    ]
  })
}
