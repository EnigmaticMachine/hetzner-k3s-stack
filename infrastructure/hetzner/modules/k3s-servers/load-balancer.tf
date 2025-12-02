# ---------------------------------------------------------------------
# UNIFIED LOAD BALANCER
# Handles Ingress (80/443) and API (6443) on a single instance.
# Cost: ~€6.90/mo
# ---------------------------------------------------------------------

resource "hcloud_load_balancer" "k3s_lb" {
  name               = "k3s-unified-lb"
  load_balancer_type = "lb11"
  location           = "fsn1"
}

# Attach LB to the private network so it can talk to nodes via private IPs
resource "hcloud_load_balancer_network" "lb_net" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  network_id       = var.network_id
  ip               = "10.0.1.3" # Static internal IP for the LB
}

# ---------------------------------------------------------------------
# SERVICES
# ---------------------------------------------------------------------

# 1. HTTP (Port 80) -> Node Port 80
resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80

  health_check {
    protocol = "tcp"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

# 2. HTTPS (Port 443) -> Node Port 443 (Passthrough)
resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443

  health_check {
    protocol = "tcp"
    port     = 443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

# 3. K3s API (Port 6443) -> Node Port 6443
# Note: This exposes the Kubernetes API to the internet.
# Ensure you use strong authentication (K3s does this by default).
resource "hcloud_load_balancer_service" "k3s_api" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

# ---------------------------------------------------------------------
# TARGETS
# ---------------------------------------------------------------------

# Dynamically add all K3s servers as targets
resource "hcloud_load_balancer_target" "targets" {
  for_each = hcloud_server.k3s_node
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  type             = "server"

  server_id = each.value.id
  use_private_ip = true
  depends_on = [hcloud_load_balancer_network.lb_net]
}

# ---------------------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------------------

output "lb_public_ip" {
  description = "Public IP for both Ingress and K3s API"
  value       = hcloud_load_balancer.k3s_lb.ipv4
}

output "lb_private_ip" {
  description = "Internal IP of the Load Balancer"
  value       = hcloud_load_balancer_network.lb_net.ip
}
