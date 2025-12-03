resource "hcloud_server" "vps" {
  name        = "bastion"
  image       = var.image_id
  server_type = "cx23"
  location    = "fsn1"

  ssh_keys = [var.ssh_key_id]
  network {
    network_id = var.network_id
    ip         = cidrhost(var.subnet_cidr, var.bastion_ip_index)
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # user_data = templatefile("${path.module}/scripts/setup.sh.tftpl", {})
  lifecycle {
    ignore_changes = [image]
  }
}
