variable "ssh_key_id" {
  description = "SSH Key ID for the node access"
  type        = string
}

variable "nodes" {
  description = "Map of node names to configuration."
  type = map(object({
    ip_suffix = number
  }))
}

# Use a Placement Group to ensure Hetzner
# puts VMs on different physical hardware for HA.
resource "hcloud_placement_group" "k3s_spread" {
  name = "k3s-spread"
  type = "spread"
}

resource "hcloud_server" "k3s_node" {
  for_each = var.nodes
  name     = each.key

  image       = var.image_id
  server_type = "cx23"
  location    = "fsn1"
  ssh_keys    = [var.ssh_key_id]

  placement_group_id = hcloud_placement_group.k3s_spread.id

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = var.network_id

    # Calculate IP using the specific suffix from map
    # "10.0.1.0/24" + 11 = 10.0.1.11
    ip = cidrhost(var.subnet_cidr, each.value.ip_suffix)
  }

  lifecycle {
    ignore_changes = [image]
  }
}
