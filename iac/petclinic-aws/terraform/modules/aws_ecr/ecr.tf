# Attach ECR ReadOnly to every discovered node role
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  for_each  = toset(local.all_node_role_names)
  role      = each.value
  policy_arn = local.policy_ecr_ro
}

# (Optional) Also ensure Worker/CNI/SSM (idempotent; safe if already attached)
resource "aws_iam_role_policy_attachment" "worker" {
  for_each  = var.ensure_base_node_policies ? toset(local.all_node_role_names) : []
  role      = each.value
  policy_arn = local.policy_worker
}

resource "aws_iam_role_policy_attachment" "cni" {
  for_each  = var.ensure_base_node_policies ? toset(local.all_node_role_names) : []
  role      = each.value
  policy_arn = local.policy_cni
}

resource "aws_iam_role_policy_attachment" "ssm" {
  for_each  = var.enable_ssm_on_nodes ? toset(local.all_node_role_names) : []
  role      = each.value
  policy_arn = local.policy_ssm
}
