variable "cluster_id" {
  type        = string
  description = "The cluster ID"
}

variable "pool_name" {
  type        = string
  description = "The name of the current pool"
}
variable "pool_size" {
  type        = string
  description = "The size of the pool"
}
variable "node_count" {
  type        = string
  description = "The node count of the pool"
}
variable "labels" {
  type        = map(string)
  description = "The labels of the pool"
}

variable "tags" {
  type        = list(any)
  description = "List of tags"
}

variable "taint" {
  type        = map(string)
  description = "A map of the key, value, and effect for the taint"
}