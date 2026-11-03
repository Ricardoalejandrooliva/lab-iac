output "AWS_ROLE_ARN" {
  value = aws_iam_role.github.arn
}

output "TF_STATE_BUCKET" {
  value = aws_s3_bucket.state.bucket
}
