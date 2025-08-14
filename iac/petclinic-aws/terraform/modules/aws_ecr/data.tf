data "aws_region" "current" {}


# Discover each existing node group to obtain its node role ARN
data "aws_eks_node_group" "ng" {
  for_each         = toset(var.node_group_names)
  cluster_name     = var.cluster_name
  node_group_name  = each.key
}

# Extract role names from ARNs, merge with any explicitly provided names
locals {
  discovered_role_names = [
    for ng in data.aws_eks_node_group.ng :
    replace(ng.node_role_arn, ".*/", "")
  ]
  all_node_role_names = distinct(concat(local.discovered_role_names, var.existing_node_role_names))
}

# Managed policy ARNs
locals {
  policy_ecr_ro  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  policy_worker  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  policy_cni     = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  policy_ssm     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
