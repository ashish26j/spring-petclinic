module "stackgen_126f2bde-24d8-4d7a-8bac-88c5bbfc1d80" {  #policy 1 - 
  source    = "./modules/aws_iam_role_policy"
  name      = "spring-petclinic-init-aws_kms-spring-petclinic-aws-policy"
  policy    = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"springpetclinicawsKMS9404c699ab155724bc9f9cc51d07b04e\",\n      \"Action\": [\n        \"kms:Decrypt\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": [\n        \"${module.stackgen_9404c699-ab15-5724-bc9f-9cc51d07b04e.arn}\"\n      ]\n    }\n  ]\n}"
  role      = module.stackgen_d581ad43-1505-5ee1-b23b-8efe2084a229.name
  role_type = "Custom"
}

module "stackgen_432c5489-277e-4f4f-b5c8-5518612e9230" {   #policy 2- s3
  source    = "./modules/aws_iam_role_policy"
  name      = "spring-petclinic-init-aws_s3-spring-petclinic-aws-policy"
  policy    = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"AllowKmsAccess\",\n      \"Action\": [\n        \"kms:Decrypt\",\n        \"kms:Encrypt\",\n        \"kms:GenerateDataKey\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": [\n        \"${module.stackgen_6c81c241-d99e-5a45-bce5-d55588c88c15.kms_arn}\"\n      ]\n    },\n    {\n      \"Sid\": \"springpetclinicawsspringpetclinicinitS3Bucket6c81c241d99e5a45bce5d55588c88c15\",\n      \"Action\": [\n        \"s3:GetObject\",\n        \"s3:GetObjectVersion\",\n        \"s3:DeleteObject\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": [\n        \"${module.stackgen_6c81c241-d99e-5a45-bce5-d55588c88c15.arn}\",\n        \"${module.stackgen_6c81c241-d99e-5a45-bce5-d55588c88c15.arn}/*\"\n      ]\n    }\n  ]\n}"
  role      = module.stackgen_d581ad43-1505-5ee1-b23b-8efe2084a229.name
  role_type = "Custom"
}


module "stackgen_5f2b1c97-d70f-512c-bc6c-da2415fd249a" { #rds
  source                            = "./modules/aws_rds"
  cluster_identifier                = null
  rds_auto_pause                    = true
  rds_availability_zones            = ["us-east-1a", "us-east-1b"]
  rds_backup_retention_period       = 9
  rds_database_name                 = "default"
  rds_db_subnet_group_name          = "default"
  rds_engine                        = "postgres"
  rds_engine_mode                   = "provisioned"
  rds_engine_version                = "16.4"
  rds_master_password               = var.rds_master_password_5f2b1c97-d70f-512c-bc6c-da2415fd249a
  rds_master_username               = "admin"
  rds_max_capacity                  = 2
  rds_min_capacity                  = 1
  rds_preferred_backup_window       = "07:00-09:00"
  rds_preferred_maintenance_window  = "sun:05:00-sun:06:00"
  rds_storage_encrypted             = true
  region                            = var.region
  security_groups                   = null
  tags                              = null
  use_custom_kms_key_for_encryption = false
}

module "stackgen_6c81c241-d99e-5a45-bce5-d55588c88c15" {  #s3
  source                       = "./modules/aws_s3"
  block_public_access          = true
  bucket_name                  = "spring-petclinic-init"
  bucket_policy                = ""
  enable_versioning            = true
  enable_website_configuration = false
  sse_algorithm                = "aws:kms"
  tags                         = {}
  website_error_document       = "404.html"
  website_index_document       = "index.html"
}

module "stackgen_9404c699-ab15-5724-bc9f-9cc51d07b04e" {  #kms
  source              = "./modules/aws_kms"
  alias               = "spring-petclinic-init"
  description         = "KMS key"
  enable_key_rotation = true
  tags                = {}
}

module "stackgen_d581ad43-1505-5ee1-b23b-8efe2084a229" {  #role will assume by eks
  source                = "./modules/aws_iam_role"
  assume_role_policy    = "{\n\t\t\"Version\": \"2012-10-17\",\n\t\t\"Statement\":{\n\t\t\t\t\"Action\": \"sts:AssumeRole\",\n\t\t\t\t\"Effect\": \"Allow\",\n\t\t\t\t\"Principal\": {\n\t\t\t\t\t\"Service\": \"eks.amazonaws.com\"\n\t\t\t\t}\n\t\t\t}\n\t}"
  description           = null
  force_detach_policies = true
  inline_policy         = []
  max_session_duration  = null
  name                  = "spring-petclinic-aws-role"
  path                  = null
  permissions_boundary  = null
  tags                  = null
}


