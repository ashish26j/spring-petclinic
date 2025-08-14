

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}


# Reuse or create the OIDC provider
resource "aws_iam_openid_connect_provider" "eks" {
  count            = var.oidc_provider_arn == null ? 1 : 0
  url              = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list   = ["sts.amazonaws.com"]
  thumbprint_list  = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}


# S3 bucket by name
data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name  #"spring-petclinic-init"
}
# KMS key by alias (most teams create alias/spring-petclinic-init)
data "aws_kms_alias" "kms" {
  name = "alias/${var.kms_keynanme}"
}

locals {
  oidc_provider_arn = coalesce(var.oidc_provider_arn, try(aws_iam_openid_connect_provider.eks[0].arn, null))
  oidc_hostpath     = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")

  bucket_arn        = data.aws_s3_bucket.bucket.arn
  object_arns       = ["${local.bucket_arn}/*"]
  kms_key_arn       = data.aws_kms_alias.kms.target_key_arn
}

module "stackgen_policy_irsa" {   #policy 3- IRSA policy for pods
  source    = "../aws_iam_role_policy"
  name      = "spring-petclinic-irsa-pod-aws-policy"
  policy    = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"S3ListBucket\",\"Effect\":\"Allow\",\"Action\":[\"s3:ListBucket\"],\"Resource\":[\"${local.bucket_arn}\"]},{\"Sid\":\"S3ObjectRW\",\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:GetObjectVersion\",\"s3:PutObject\",\"s3:DeleteObject\",\"s3:AbortMultipartUpload\"],\"Resource\":${jsonencode(local.object_arns)}},{\"Sid\":\"KMSUseKey\",\"Effect\":\"Allow\",\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:ReEncrypt*\",\"kms:GenerateDataKey*\",\"kms:DescribeKey\"],\"Resource\":[\"${local.kms_key_arn}\"]},{\"Sid\":\"KMSList\",\"Effect\":\"Allow\",\"Action\":[\"kms:ListKeys\",\"kms:ListAliases\"],\"Resource\":\"*\"}]}"
  role      = module.stackgen_role_irsa.name
  role_type = "Custom"
}

module "stackgen_role_irsa" {  #role will assume by pod in eks for aws services interaction
  source                = "../aws_iam_role"
  assume_role_policy    = "{\n\t\"Version\": \"2012-10-17\",\n\t\"Statement\": [\n\t\t{\n\t\t\t\"Effect\": \"Allow\",\n\t\t\t\"Action\": \"sts:AssumeRoleWithWebIdentity\",\n\t\t\t\"Principal\": {\n\t\t\t\t\"Federated\": \"${local.oidc_provider_arn}\"\n\t\t\t},\n\t\t\t\"Condition\": {\n\t\t\t\t\"StringEquals\": {\n\t\t\t\t\t\"${local.oidc_hostpath}:aud\": \"sts.amazonaws.com\",\n\t\t\t\t\t\"${local.oidc_hostpath}:sub\": \"system:serviceaccount:${var.sa_namespace}:${var.sa_name}\"\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\t]\n}"
  description           = null
  force_detach_policies = true
  inline_policy         = []
  max_session_duration  = null
  name                  = var.role_name
  path                  = null
  permissions_boundary  = null
  tags                  = null
}

output "irsa_role_arn" {
  value       = aws_iam_role.irsa.arn
  description = "Annotate your ServiceAccount with this ARN (eks.amazonaws.com/role-arn)."
}