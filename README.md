# Hetzner K3s Stack: The Hyperscaler Exit Strategy

**A pragmatic, batteries-included framework for running production workloads on cost-effective infrastructure.**

[](https://opensource.org/licenses/MIT)
[](https://www.terraform.io/)
[](https://www.ansible.com/)
[](https://www.docker.com/)

-----

## Overview

**hetzner-k3s-stack** is a reference architecture for startups and SMBs who have outgrown Heroku but are tired of the "AWS Tax."

It deploys a secure, fully-hardened **High-Availability Kubernetes (K3s)** cluster on Hetzner Cloud in under 10 minutes. Unlike generic tutorials, this framework treats infrastructure as a product. It solves the hard parts of self-hosting—**HA Database patterns, Ingress, Security, and State Management**—so you can focus on shipping code, not configuring control planes.

### Philosophy: "Pragmatic Resilience"

We believe in **99.9% uptime for 20% of the cost**. We prioritize **Mean Time To Recovery (MTTR)** and simplicity over the illusion of "five nines" complexity. We build systems that expect failure and recover from it automatically.

-----

## Architecture

This framework deploys a **Hyper-Converged Architecture** to maximize performance per dollar while maintaining high availability.

```mermaid
```

-----

## Features

  * **Bastion-Centric Security:** Zero public SSH ports on cluster nodes. All management traffic is strictly tunneled through a hardened Bastion host using SSH keys.
  * **True High Availability:** 3-node K3s Control Plane with embedded etcd. The cluster survives single-node failures automatically.
  * **Bare-Metal Performance:** By default, we use **Local Path Provisioning** (NVMe) combined with **Application-Level Replication** (CNPG). This avoids the I/O overhead of distributed storage for maximum database speed.
  * **Automated Ingress:** **Traefik** + **Cert-Manager** pre-configured to handle automatic Let's Encrypt SSL certificates.
  * **Zero-Dependency Toolchain:** All logic runs inside a transient Docker container. No local Terraform/Ansible version conflicts.
  * **"Magic" DNS:** Uses `nip.io` by default to provide instant, valid HTTPS URLs (`https://demo.49.x.x.x.nip.io`) without touching your DNS provider.

-----

## The Economics

Why move? The savings are undeniable.

| Component | AWS / EKS (Approx) | Hetzner K3s Stack |
| :--- | :--- | :--- |
| **Control Plane** | $72/mo (EKS) | **$0\*\* (Included) |
| **Compute (x3 HA Nodes)** | $120/mo (t3.medium) | **\~€20/mo** (CX22/CX32) |
| **Database (HA)** | $140/mo (RDS Multi-AZ) | **€0** (Included on Nodes) |
| **Bandwidth (1TB)** | $90/mo (NAT/Egress) | **€0** (20TB Included) |
| **Total Monthly** | **~$422 / mo\*\* | **\~€25 / mo** |

*You get 95% of the capability for \<10% of the price.*

-----

## Quick Start

### Prerequisites

1.  **Docker** installed on your local machine.
2.  A [Hetzner Cloud](https://console.hetzner.cloud/) API Token.

### 1\. Configure Credentials

```bash
# Required: Your Hetzner API Token
export HCLOUD_TOKEN="your-api-token"

# Optional: Remote State (Highly Recommended for Teams)
# If skipped, Terraform state is stored locally in the repo.
export AWS_ACCESS_KEY_ID="your-hetzner-s3-access-key"
export AWS_SECRET_ACCESS_KEY="your-hetzner-s3-secret-key"
```

### 2\. Launch the Cluster

This single command spins up the toolchain container, provisions hardware (Terraform), generates the dynamic inventory, and configures the OS/K3s (Ansible).

```bash
make deploy
```

### 3\. Access Your Cluster

Once complete (approx. 10 minutes), the CLI will output your dashboard URLs and credentials.

```text
Deployment Complete!
   ------------------------------------------------
   - Dashboard: https://grafana.49.168.10.20.nip.io
   - Demo App:  https://django.49.168.10.20.nip.io
   - Username:  admin
   - Password:  [Generated-Password]
   ------------------------------------------------
```

-----

## Configuration

Control your stack via `cluster-config.yaml`. No need to edit Terraform code directly.

```yaml
project_name: "test-env"

# "Magic Mode": Leave empty to use <lb-ip>.nip.io
# "Prod Mode": Set to your domain (requires manual DNS A-record)
base_domain: ""

infrastructure:
  region: "fsn1"        # Nuremberg
  node_count: 3         # HA Control Plane
  node_type: "cx32"     # Recommended: 4vCPU / 8GB RAM

features:
  monitoring: true      # Prometheus/Grafana Stack
  demo_app: true        # Django HA Demo
```

-----

## Production Readiness Guide

This repository deploys the **"Launchpad" Architecture**. It is designed for maximum cost-efficiency by running Workloads, Storage, and the Control Plane on the same nodes.

  * **Perfect for:** Staging, MVPs, Development, and Cost-Sensitive Startups.
  * **The Trade-off:** Extremely high disk I/O (e.g., from a massive database import) can impact Etcd latency, potentially causing momentary cluster instability.

### Graduation Path (The "Scale-Up")

For mission-critical production workloads, we recommend graduating to a **Split Architecture**:

1.  **Dedicated Control Plane:** 3x nodes running *only* K3s/Etcd.
2.  **Dedicated Worker Pools:** Scalable nodes for applications.
3.  **Distributed Storage:** Implementing Longhorn or Rook/Ceph for RWX volumes.
4.  **DNS Strategy:** Moving from `nip.io` to Cloudflare/Route53.

*This framework supports these patterns via configuration, but defaults to the hyper-converged model for accessibility.*

-----

## Managed Services

This repository is Open Source (MIT). You are free to use it to build your own infrastructure.

**Need a partner?**
I offer **Fixed-Price DevOps Services** for SMBs. I can deploy, manage, and monitor this stack for you, saving you the cost of a full-time DevOps engineer.

  * **Migration Assistance:** Move from AWS/Heroku/DigitalOcean to Hetzner.
  * **24/7 Monitoring:** Proactive alerts and incident response.
  * **Security Patching:** Weekly updates and CIS benchmark audits.

[**Contact Me**](mailto:michael@steezr.com) | [**Book a Free Architecture Audit**]
