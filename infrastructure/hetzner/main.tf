# You need to setup env variables, if you have Terraform state on S£:
# export AWS_ACCESS_KEY_ID=<HETZNER-STORAGE-ACCESS-KEY>
# export AWS_SECRET_ACCESS_KEY=<HETZNER-STORAGE-SECRET-KEY>

data "hcloud_image" "debian-12" {
  name = "debian-12"
}

resource "hcloud_ssh_key" "main" {
  name       = "k3s-admin-key"
  public_key = var.ssh_public_key
}

resource "hcloud_network" "private_network" {
  name     = "k3s-private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_network_route" "internet_access" {
  network_id  = hcloud_network.private_network.id
  destination = "0.0.0.0/0"
  gateway     = module.bastion.private_ip
}

module "bastion" {
  source           = "./modules/bastion"
  image_id         = data.hcloud_image.debian-12.id
  subnet_id        = hcloud_network_subnet.private_subnet.id
  ssh_key_id       = hcloud_ssh_key.main.id
  network_id       = hcloud_network.private_network.id
  subnet_cidr      = hcloud_network_subnet.private_subnet.ip_range
  bastion_ip_index = 2
}

module "k3s_servers" {
  source      = "./modules/k3s-servers"
  network_id  = hcloud_network.private_network.id
  image_id    = data.hcloud_image.debian-12.id
  ssh_key_id  = hcloud_ssh_key.main.id
  subnet_cidr = hcloud_network_subnet.private_subnet.ip_range

  nodes = {
    "control-plane-1" = { ip_suffix = 11 }
    "control-plane-2" = { ip_suffix = 12 }
    "control-plane-3" = { ip_suffix = 13 }
    # Future scaling: just add "worker-1" = { ip_suffix = 21 }
  }
}
