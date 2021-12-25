terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11.1"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

locals {
  cluster_name = format("%s-%s", var.cluster_name, var.region)
  common_tags  = [local.cluster_name, "ethereum-kubernetes"]
}

data "digitalocean_kubernetes_versions" "main" {
  version_prefix = var.digitalocean_kubernetes_versions # list available options with `doctl kubernetes options versions`
}

resource "digitalocean_domain" "default" {
  name = var.digitalocean_domain
}

resource "digitalocean_vpc" "main" {
  name     = local.cluster_name
  region   = var.region
  ip_range = var.digitalocean_vpc_ip_range
}

resource "digitalocean_kubernetes_cluster" "main" {
  name     = local.cluster_name
  region   = var.region
  version  = data.digitalocean_kubernetes_versions.main.latest_version
  vpc_uuid = digitalocean_vpc.main.id
  tags     = local.common_tags

  node_pool {
    name       = "${local.cluster_name}-default"
    size       = var.kubernetes_cluster_main_values.size
    labels     = var.kubernetes_cluster_main_values.labels
    node_count = var.kubernetes_cluster_main_values.node_count
    tags       = concat(local.common_tags, ["default"])
  }

}

# Firewall to open up NodePort range
resource "digitalocean_firewall" "firewall" {
  name = local.cluster_name

  tags = [local.cluster_name]

  dynamic "inbound_rule" {
    for_each = var.firewall_rules.inbound_rules
    content {
      protocol         = inbound_rule.value["protocol"]
      port_range       = inbound_rule.value["port_range"]
      source_addresses = inbound_rule.value["source_addresses"]
    }
  }

  dynamic "outbound_rule" {
    for_each = var.firewall_rules.outbound_rules
    content {
      protocol              = outbound_rule.value["protocol"]
      port_range            = try(outbound_rule.value["port_range"], null)
      destination_addresses = outbound_rule.value["destination_addresses"]
    }
  }

}

# Dedicated pool of nodes for ethereum clients

module "kubernetes_node_pools" {
  source   = "../../modules/digitalocean_kubernetes_node_pool/"
  for_each = { for node_pool in var.kubernetes_node_pools : node_pool.name => node_pool }

  cluster_id = digitalocean_kubernetes_cluster.main.id
  pool_name  = "${local.cluster_name}-${each.value.name}"
  pool_size  = each.value.size
  node_count = each.value.node_count
  tags       = concat(local.common_tags, each.value.tags)
  labels     = each.value.labels
  taint      = each.value.taint

}