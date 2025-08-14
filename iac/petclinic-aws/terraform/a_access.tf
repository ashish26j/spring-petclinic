module "stackgen_ecraccess" {
  //This will ensure that all node-group will  have ECR pull access
  source                    = "./modules/aws_ecr"
  cluster_name              = "aks"
  node_group_names          = ["aks-ng1", "aks-ng2"]
  existing_node_role_names  = ["aks-ng-role1", "aks-ng-role2"]
  enable_ssm_on_nodes       = true
  ensure_base_node_policies = true
}


module "stackgen_irsa" {
//This role ensure pods to interact with AWS  services if required
  source       = "./modules/aws_irsa"
  cluster_name = "aks"
  sa_name      = "sa-petclinic"
  sa_namespace = "ns-petclinic"
  bucket_name  = "spring-petclinic-init"
  kms_keynanme = "spring-petclinic-init"
  role_name    = "spring-petclinic-aws-irsa-pod-role"
}
