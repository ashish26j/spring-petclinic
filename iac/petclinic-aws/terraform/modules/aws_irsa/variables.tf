
variable "cluster_name"  { 
    type = string
    default = "akseks" 
    }
variable "sa_namespace"  { 
    type = string
    default = "default" 
 }     # <-- set your namespace
variable "sa_name"       { 
    type = string
    default = "app-sa" 
    }      # <-- set your ServiceAccount name

# If the cluster's OIDC provider already exists, you can pass its ARN; otherwise we'll create it.
variable "oidc_provider_arn" { 
    type = string
 default = null 
 }

 variable "bucket_name" { 
    type = string
 default = null 
 }

 variable "kms_keynanme" {
   type = string
   default = null
 }

 variable "role_name" {
   type = string
   default = null
 }