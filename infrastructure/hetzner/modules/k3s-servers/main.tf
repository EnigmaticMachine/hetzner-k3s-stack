terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
  }
}

variable "network_id" {
  description = "The ID of the private network to attach servers to."
  type        = string
}


variable "image_id" {
  description = "The ID of the server image to use."
  type        = string
}
