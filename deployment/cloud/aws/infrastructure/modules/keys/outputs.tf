output "kms_key_arn_west" {
  value = aws_kms_key.west.arn
}

output "kms_key_arn_east" {
  value = aws_kms_key.east.arn
}