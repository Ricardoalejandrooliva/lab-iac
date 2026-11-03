output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "instance_id" {
  value = aws_instance.web.id
}

output "instance_type" {
  value = aws_instance.web.instance_type
}

output "bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "security_group_id" {
  value = aws_security_group.web.id
}
