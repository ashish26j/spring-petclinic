variable "region" {
  description = "AWS region in which the project needs to be setup (us-east-1, ca-west-1, eu-west-3, etc)"
}

variable "rds_master_password_5f2b1c97-d70f-512c-bc6c-da2415fd249a" {
  default     = "password"
  description = "Password for the master DB user"
  type        = string
  nullable    = false
  sensitive   = true
}

