resource "hcloud_server" "vps" {
  name        = "bastion"
  image       = var.image_id
  server_type = "cx33"
  location    = "fsn1"

  ssh_keys = [var.ssh_key_id]
  network {
    network_id = var.network_id
    ip         = "10.0.1.1"
  }

  user_data = <<-EOT
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables-save > /etc/iptables/rules.v4
  EOT

  lifecycle {
    ignore_changes = [image]
  }
}
