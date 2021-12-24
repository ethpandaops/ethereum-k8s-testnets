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
  default = "ams3" # list available regions with `doctl compute region list`
}

variable "cluster_name" {
  type    = string
  default = "eth-k8s-merge-kintsugi"
}

locals {
  cluster_name = format("%s-%s", var.cluster_name, var.region)
  common_tags = [ local.cluster_name, "ethereum-kubernetes" ]
}

data "digitalocean_kubernetes_versions" "main" {
  version_prefix = "1.21.5" # list available options with `doctl kubernetes options versions`
}

resource "digitalocean_domain" "default" {
  name       = "kintsugi.themerge.dev"
}

resource "digitalocean_vpc" "main" {
  name     = local.cluster_name
  region   = var.region
  ip_range = "10.120.0.0/16"
}

resource "digitalocean_kubernetes_cluster" "main" {
  name     = local.cluster_name
  region   = var.region
  version  = data.digitalocean_kubernetes_versions.main.latest_version
  vpc_uuid = digitalocean_vpc.main.id
  tags     = local.common_tags

  node_pool {
    name       = "${local.cluster_name}-default"
    size       = "s-4vcpu-8gb-amd" # list available options with `doctl compute size list`
    labels = {
      priority  = "high"
      service   = "default"
    }
    node_count = 2
    tags       = concat(local.common_tags, ["default"])
  }

}

# Firewall to open up NodePort range
resource "digitalocean_firewall" "firewall" {
  name = local.cluster_name

  tags = [local.cluster_name]

  inbound_rule {
    protocol         = "udp"
    port_range       = "30000-32768"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32768"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Dedicated pool of nodes for ethereum clients
resource "digitalocean_kubernetes_node_pool" "clients" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${local.cluster_name}-clients"
  size       = "s-4vcpu-8gb-amd" # $48/month
  node_count  = 15
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
  name       = "${local.cluster_name}-beaconexplorer"
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
  name       = "${local.cluster_name}-blockscout"
  #size       = "so-2vcpu-16gb"    # $125/month (300GB NVMe)
  size       = "so1_5-2vcpu-16gb" # $155/month (450GB NVMe)
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
  name       = "${local.cluster_name}-prometheus"
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
