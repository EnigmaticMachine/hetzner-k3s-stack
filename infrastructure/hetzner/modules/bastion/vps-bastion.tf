resource "hcloud_server" "vps" {
  name        = "bastion"
  image       = var.image_id
  server_type = "cx23"
  location    = "fsn1"

  ssh_keys = [var.ssh_key_id]
  network {
    network_id = var.network_id
    ip         = "10.0.1.1"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = <<-EOT
      #!/bin/bash
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y iptables-persistent

      # Enable IPv4 Forwarding (Immediate + Permanent)
      sysctl -w net.ipv4.ip_forward=1
      sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

      # Apply NAT Rule
      iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

      # Save rules so they load on reboot
      netfilter-persistent save
    EOT

  lifecycle {
    ignore_changes = [image]
  }
}
