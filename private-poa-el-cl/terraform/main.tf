terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.11.1"
    }
  }
}

variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

variable "region" {
  type    = string
  default = "fra1" # list available regions with `doctl compute region list`
}

variable "cluster_name" {
  type    = string
  default = "eth-k8s"
}

locals {
  common_tags = [ var.cluster_name, "ethereum-kubernetes" ]
}

data "digitalocean_kubernetes_versions" "main" {
  version_prefix = "1.21.5" # list available options with `doctl kubernetes options versions`
}

resource "digitalocean_vpc" "main" {
  name     = format("%s-%s", var.cluster_name, var.region)
  region   = var.region
  ip_range = "10.100.0.0/16"
}

resource "digitalocean_kubernetes_cluster" "main" {
  name     = var.cluster_name
  region   = var.region
  version  = data.digitalocean_kubernetes_versions.main.latest_version
  vpc_uuid = digitalocean_vpc.main.id
  tags     = local.common_tags

  node_pool {
    name       = "${var.cluster_name}-default"
    size       = "s-4vcpu-8gb-amd" # list available options with `doctl compute size list`
    labels = {
      priority  = "high"
      service   = "default"
    }
    node_count = 2
    tags       = concat(local.common_tags, ["default"])
  }

}

# Dedicated pool of nodes for ethereum clients
resource "digitalocean_kubernetes_node_pool" "clients" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${var.cluster_name}-clients"
  size       = "s-4vcpu-8gb-amd" # $48/month
  auto_scale = true
  min_nodes  = 10
  max_nodes  = 10
  tags       = concat(local.common_tags, ["clients"])

  labels = {
    dedicated  = "clients"
  }
  taint {
    key    = "dedicated"
    value  = "clients"
    effect = "NoSchedule"
  }
}

# Dedicated pool of nodes for the beacon explorer
resource "digitalocean_kubernetes_node_pool" "beaconexplorer" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${var.cluster_name}-beaconexplorer"
  size       = "so1_5-2vcpu-16gb" # $155/month (450GB NVMe)
  node_count = 1
  tags       = concat(local.common_tags, ["beaconexplorer"])

  labels = {
    dedicated  = "beaconexplorer"
  }
  taint {
    key    = "dedicated"
    value  = "beaconexplorer"
    effect = "NoSchedule"
  }
}

# Dedicated pool of nodes for the blockscout explorer
resource "digitalocean_kubernetes_node_pool" "blockscout" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${var.cluster_name}-blockscout"
  size       = "so-2vcpu-16gb" # $125/month (300GB NVMe)
  node_count = 1
  tags       = concat(local.common_tags, ["blockscout"])

  labels = {
    dedicated  = "blockscout"
  }
  taint {
    key    = "dedicated"
    value  = "blockscout"
    effect = "NoSchedule"
  }
}

# Dedicated pool of nodes for prometheus
resource "digitalocean_kubernetes_node_pool" "prometheus" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${var.cluster_name}-prometheus"
  size       = "m3-4vcpu-32gb" # $195/month (100GB SSD)
  node_count = 1
  tags       = concat(local.common_tags, ["prometheus"])

  labels = {
    dedicated  = "prometheus"
  }
  taint {
    key    = "dedicated"
    value  = "prometheus"
    effect = "NoSchedule"
  }
}
