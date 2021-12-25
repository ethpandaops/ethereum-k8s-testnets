variable "do_token" {
  type        = string
  description = "The API token value, best to provide this value via the command line!"
}

variable "region" {
  type    = string
  default = "ams3" # list available regions with `doctl compute region list`
}

variable "cluster_name" {
  type    = string
  default = "eth-k8s-merge-kintsugi"
}

variable "digitalocean_kubernetes_versions" {
  type        = string
  description = "The Kubernetes version, within DO that needs to be used"
  default     = "1.21.5"
}

variable "digitalocean_domain" {
  type        = string
  description = "The digital ocean domain created for your cluster"
  default     = "kintsugi.themerge.dev"
}

variable "digitalocean_vpc_ip_range" {
  type        = string
  description = "IP range of your VPC"
  default     = "10.120.0.0/16"
}

variable "firewall_rules" {
  description = "Firewall rules"
  default = {
    inbound_rules = [
      {
        protocol         = "udp"
        port_range       = "30000-32768"
        source_addresses = ["0.0.0.0/0", "::/0"]
      },
      {
        protocol         = "tcp"
        port_range       = "30000-32768"
        source_addresses = ["0.0.0.0/0", "::/0"]
      },
    ]
    outbound_rules = [
      {
        protocol              = "tcp"
        port_range            = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
      },
      {
        protocol              = "udp"
        port_range            = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
      },
      {
        protocol              = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
      }
    ]
  }
}

variable "kubernetes_cluster_main_values" {
  description = "Values for the main Kubernetes Cluster"
  default = {
    size = "s-4vcpu-8gb-amd"
    labels = {
      priority = "high"
      service  = "default"
    }
    node_count = 2
  }
}

variable "kubernetes_node_pools" {
  description = "A configuration map of all the node pools to be created"
  default = [
    {
      name = "clients"
      size = "s-4vcpu-8gb-amd"
      labels = {
        dedicated = "clients"
      }
      node_count = 15
      taint = {
        key    = "dedicated"
        value  = "clients"
        effect = "NoSchedule"
      }
      tags = ["clients"]
    },
    {
      name = "beaconexplorer"
      size = "so1_5-2vcpu-16gb"
      labels = {
        dedicated = "beaconexplorer"
      }
      node_count = 1
      taint = {
        key    = "dedicated"
        value  = "beaconexplorer"
        effect = "NoSchedule"
      }
      tags = ["beaconexplorer"]
    },
    {
      name = "blockscout"
      size = "so1_5-2vcpu-16gb"
      labels = {
        dedicated = "blockscout"
      }
      node_count = 1
      taint = {
        key    = "dedicated"
        value  = "blockscout"
        effect = "NoSchedule"
      }
      tags = ["blockscout"]
    },
    {
      name = "prometheus"
      size = "m3-4vcpu-32gb"
      labels = {
        dedicated = "prometheus"
      }
      node_count = 1
      taint = {
        key    = "dedicated"
        value  = "prometheus"
        effect = "NoSchedule"
      }
      tags = ["prometheus"]
    },
  ]
}