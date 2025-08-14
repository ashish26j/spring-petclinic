variable "cluster_name" {
  description = "Existing EKS cluster name"
  type        = string
  default     = "akseks"
}

# Put your real node group names here (one or many)
variable "node_group_names" {
  description = "Existing EKS managed node group names"
  type        = list(string)
  default     = ["ng-workers"]   # ← change to your NG name(s)
}

# If you prefer to pass role names directly, add them here; we'll merge both.
variable "existing_node_role_names" {
  description = "Optional: node IAM role names (if you already know them)"
  type        = list(string)
  default     = []
}

# Optional helpers
variable "ensure_base_node_policies" {
  description = "Also ensure Worker/CNI policies are attached"
  type        = bool
  default     = false
}
variable "enable_ssm_on_nodes" {
  description = "Also attach SSM policy so you can SSM into nodes"
  type        = bool
  default     = false
}
