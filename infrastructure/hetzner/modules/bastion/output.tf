output "private_ip" {
  value = tolist(hcloud_server.vps.network)[0].ip
}
