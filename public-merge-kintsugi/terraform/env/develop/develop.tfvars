region                           = "ams3"
cluster_name                     = "develop-eth-k8s-merge-kintsugi-1"
digitalocean_kubernetes_versions = "1.21.5"
digitalocean_domain              = "kintsugi.themerge.dev"
digitalocean_vpc_ip_range        = "10.120.0.0/16"
# list available options with `doctl compute size list`
kubernetes_cluster_main_values = {
  size = "s-1vcpu-1gb"
  labels = {
    priority = "high"
    service  = "default"
  }
  node_count = 1
}
firewall_rules = {
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

kubernetes_node_pool = [
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