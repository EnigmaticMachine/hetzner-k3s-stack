# --- 1. Network & Bastion ---
module "bastion" {
  source   = "./modules/bastion"
  image_id = "debian-12"
}

# --- 2. The 3 HA Nodes (Converged Control Plane + Worker) ---
resource "hcloud_server" "k3s_node" {
  count       = 3
  name        = "k3s-node-${count.index + 1}"
  server_type = "cx32" 
  image       = "debian-12"
  location    = "fsn1"

  user_data = <<-EOT
    #cloud-config
    users:
      - name: ops-admin
        groups: sudo, docker
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    package_update: true
    packages:
      - python3
      - curl
      - open-iscsi
      - nfs-common
    runcmd:
      - systemctl enable --now iscsid
  EOT

  network {
    network_id = module.bastion.private_network_id
    ip         = "10.0.1.1${count.index + 1}"
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
}

# --- 3. Load Balancer ---
resource "hcloud_load_balancer" "lb" {
  name               = "k3s-lb"
  load_balancer_type = "lb11"
  location           = "fsn1"
}

resource "hcloud_load_balancer_network" "lb_net" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = module.bastion.private_network_id
  ip               = "10.0.1.2"
}

resource "hcloud_load_balancer_target" "lb_targets" {
  count            = 3
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.k3s_node[count.index].id
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
}

resource "hcloud_load_balancer_service" "k8s_api" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}
