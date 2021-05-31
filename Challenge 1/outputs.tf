output "bucket_id" {
  value = aws_s3_bucket.flugelbucket.id
}

output "instance_name" {
  value = aws_instance.flugelinstance.id
}
