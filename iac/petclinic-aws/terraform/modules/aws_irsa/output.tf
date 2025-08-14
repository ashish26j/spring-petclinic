output "irsa_role_arn" {
  value       = aws_iam_role.irsa.arn
  description = "Annotate your ServiceAccount with this ARN (eks.amazonaws.com/role-arn)."
}