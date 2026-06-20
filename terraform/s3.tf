resource "aws_s3_bucket_notification" "notify" {

  bucket = aws_s3_bucket.demo.id

  queue {
    queue_arn = aws_sqs_queue.demo.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.allow_s3]
}
