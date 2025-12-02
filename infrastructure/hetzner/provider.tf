terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
