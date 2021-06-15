output "bucket_id" {
  value = aws_s3_bucket.flugel-bucket.id
}

output "instance_name_web1" {
  value = aws_instance.web1.id
}

output "instance_name_web2" {
  value = aws_instance.web2.id
}

output "load_balancer_url" {
  value = aws_alb.flugel-alb.dns_name
}
