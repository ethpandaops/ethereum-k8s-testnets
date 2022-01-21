terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11.1"
    }
  }
}
resource "digitalocean_kubernetes_node_pool" "pool" {
  cluster_id = var.cluster_id
  name       = var.pool_name
  size       = var.pool_size
  node_count = var.node_count
  tags       = var.tags

  labels = var.labels
  taint {
    key    = var.taint.key
    value  = var.taint.value
    effect = var.taint.effect
  }
}
