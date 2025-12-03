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

variable "bastion_ip_index" {
  description = "The host index for the bastion (e.g., 1 for 10.0.0.1)"
  type        = number
  default     = 1
}

variable "subnet_cidr" {
  type = string
}
