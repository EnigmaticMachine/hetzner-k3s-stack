variable "hcloud_token" { sensitive = true }
variable "ssh_public_key" { 
  description = "Public Key to inject into the Bastion and K3s nodes"
}
