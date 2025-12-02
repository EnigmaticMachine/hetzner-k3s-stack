variable "ssh_key_id" { type = string }
variable "subnet_id" { type = string }

variable "network_id" {
  description = "The ID of the private network"
  type        = string
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
  }
}

variable "image_id" {
  description = "The ID of the server image to use."
  type        = string
}
