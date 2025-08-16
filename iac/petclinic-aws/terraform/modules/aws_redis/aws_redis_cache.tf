resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cache_name}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.cache_name}-sg"
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  tags = var.tags
}

# Firewall-style access: allow traffic on 6379 from allowed CIDRs
resource "aws_security_group_rule" "allow_ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.redis_sg.id
  cidr_blocks       = var.allowed_cidrs
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis_sg.id
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.cache_name
  description = var.description

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  # HA setup
  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group

  automatic_failover_enabled = var.automatic_failover
  multi_az_enabled           = var.multi_az

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.redis_sg.id]

  at_rest_encryption_enabled = var.at_rest_encryption
  transit_encryption_enabled = var.transit_encryption
  auth_token                 = var.auth_token

  maintenance_window = var.maintenance_window

  snapshot_retention_limit = var.snapshot_retention
  snapshot_window          = var.snapshot_window

  tags = merge(var.tags, { Name = var.cache_name })
}
