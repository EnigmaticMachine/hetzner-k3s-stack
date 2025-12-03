variable "hcloud_token" { sensitive = true }

variable "ssh_public_key" {
  description = "Public Key to inject into the Bastion and K3s nodes"
}

variable "nodes" {
  description = "Map of node names to configuration."
  type = map(object({
    ip_suffix = number
  }))

  default = {
    "k3s-server-1" = { ip_suffix = 11 }
    "k3s-server-2" = { ip_suffix = 12 }
    "k3s-server-3" = { ip_suffix = 13 }
  }

  validation {
    condition     = alltrue([for k, v in var.nodes : v.ip_suffix > 1 && v.ip_suffix < 254])
    error_message = "IP suffix must be a valid host number between 2 and 253."
  }
}
