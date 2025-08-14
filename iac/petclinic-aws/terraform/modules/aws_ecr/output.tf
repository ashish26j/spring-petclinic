output "node_role_names" {
  value       = local.all_node_role_names
  description = "Roles that received ECR read permission"
}
