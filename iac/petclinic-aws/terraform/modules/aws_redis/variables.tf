variable "cache_name" {
  description = "Name of the Redis replication group"
  type        = string
}

variable "description" {
  description = "Description of the replication group"
  type        = string
  default     = "Managed Redis cluster"
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Instance type for Redis nodes"
  type        = string
  default     = "cache.t4g.small"
}

variable "port" {
  description = "Port Redis listens on"
  type        = number
  default     = 6379
}

variable "num_node_groups" {
  description = "Number of node groups (1 for cluster mode disabled)"
  type        = number
  default     = 1
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group"
  type        = number
  default     = 1
}

variable "automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnets for the Redis subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where Redis will run"
  type        = string
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to connect to Redis"
  type        = list(string)
  default     = []
}

variable "at_rest_encryption" {
  description = "Enable at-rest encryption"
  type        = bool
  default     = true
}

variable "transit_encryption" {
  description = "Enable TLS for in-transit encryption"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Auth token for Redis (16–128 chars). Required if TLS enabled."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:02:00-sun:07:00"
}

variable "snapshot_retention" {
  description = "Number of days for which to retain snapshots"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Daily time range for taking snapshots"
  type        = string
  default     = "05:00-07:00"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
