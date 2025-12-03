# Hetzner K3s Stack: The Hyperscaler Exit Strategy

**A pragmatic, batteries-included framework for running production workloads on cost-effective infrastructure.**

[](https://opensource.org/licenses/MIT)
[](https://www.terraform.io/)
[](https://www.ansible.com/)
[](https://www.docker.com/)

-----

** Status: Open-Sourcing Production Core (v0.1)**

I am currently in the process of **generalizing** the Ansible automation to remove client-specific business logic, proprietary tooling, and hardcoded secrets.

| Component | Status | Notes |
| :--- | :--- | :--- |
| **Infrastructure (Terraform)** | **Stable** | Identical to the production modules running in live environments. |
| **Configuration (Ansible)** | **Generalizing** | Currently stripping out client-specific data to make the roles generic. |
| **Architecture** | **Production-ready** | The design patterns (HA, Security, Storage) are battle-tested on production workloads. |

---

## Overview

**hetzner-k3s-stack** is a reference architecture for startups and SMBs who have outgrown Heroku but are tired of the "AWS Tax."

It deploys a secure, fully-hardened **High-Availability Kubernetes (K3s)** cluster on Hetzner Cloud in under 10 minutes. Unlike generic tutorials, this framework treats infrastructure as a product. It solves the hard parts of self-hosting—**HA Database patterns, Ingress, Security, and State Management**—so you can focus on shipping code, not configuring control planes.

---

## Real-World Deployments

This architecture is deployed in active production environments to address specific scaling and cost-efficiency requirements for high-traffic clients.

### Case Study A: Symmy.com (Enterprise Integration)
* **The Workload:** Middleware infrastructure synchronizing data between legacy ERP systems (Pohoda, Helios, Abra) and modern e-commerce marketplaces (Allegro, Shopify).
* **The Implementation:** Deployed this K3s stack to handle high-concurrency API requests required for real-time inventory and order synchronization.
* **The Result:** Achieved cost effective consistent data throughput for critical B2B integration streams.

### Case Study B: OD Máj (Public Venue)
* **The Workload:** Digital infrastructure for a high-traffic physical venue (tens of thousands of daily visitors). The system supports public-facing web applications running primarily on WordPress.
* **The Implementation:** Migrated workloads from Google Cloud Platform (GCP) to this self-hosted K3s architecture to transition from variable to fixed infrastructure pricing.
* **The Result:** Established a highly reliable infrastructure with a predictable, flat monthly cost structure.

---


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

## Quick Start (Alpha Manual Mode)

> **Alpha Notice:** The automatic "glue" script is currently being refactored. For this version, we will provision the infrastructure and then manually update the Ansible inventory.

### 1\. Provision Infrastructure (Terraform)

First, we create the infra layer.

**A. Prepare your credentials:**

1.  **Hetzner Token:** Go to [Hetzner Console](https://console.hetzner.cloud/) -\> Select Project -\> **Security** -\> **API Tokens** -\> **Generate API Token** (Read/Write).
2.  **SSH Key:** Copy the contents of your local public key (e.g., `cat ~/.ssh/id_ed25519.pub`).

**B. Run Terraform:**

```bash
cd infrastructure/hetzner

# Initialize providers
terraform init

# Apply infrastructure
terraform apply
```

**C. Enter Credentials when prompted:**

  * `var.hcloud_token`: Paste your Hetzner API Token.
  * `var.ssh_public_key`: Paste the text content of your public SSH key (starts with `ssh-ed25519...` or `ssh-rsa...`).

> **Note:** Once Terraform finishes, keep the terminal open. You will need the **Outputs** (IP addresses) for the next step.

-----

### 2\. Configure Inventory

Now we need to tell Ansible where the new servers are.

**A. Update the Bastion Host:**
Open `automation/hosts.ini` in your editor.
1. Replace `REPLACE_WITH_BASTION_IP` with the **Public IP** of the Bastion from Terraform outputs.
2. Ensure `ansible_ssh_private_key_file` points to the private key matching the public key you provided to Terraform.

```ini
# automation/hosts.ini
[bastion]
bastion ansible_host=49.12.xx.xx ansible_user=root ...
```

**B. Update the Load Balancer VIP:**
Open `automation/vars.yml`. Replace `REPLACE_WITH_LB_IP` with the **Public IP** of the Load Balancer output from Terraform.

```yaml
# automation/vars.yml
# INFRASTRUCTURE (From Terraform)
lb_public_ip: "91.98.xx.xx"
```

-----

### 3\. Bootstrap Cluster (Ansible)

Finally, we apply the configuration layers. Run these playbooks in specific order to establish the secure tunnel before attempting to install Kubernetes.

```bash
cd ../../automation

# 1. Harden Bastion & Setup Squid Proxy
# (This creates the secure tunnel for the private nodes)
ansible-playbook -i hosts.ini roles/bastion/01_init_setup.yml

# 2. Configure Proxy Envs on Nodes
# (Ensures nodes use the Bastion to reach the internet)
ansible-playbook -i hosts.ini roles/k3s/01_proxy_setup.yml

# 3. Setup Private Networking
# (Configures internal routing and disables Cloud-Init)
ansible-playbook -i hosts.ini roles/k3s/02_setup_network.yml

# 4. Install K3s Cluster
# (Bootstraps the HA Control Plane)
ansible-playbook -i hosts.ini roles/k3s/03_install_server_nodes.yml
```

### 4\. Verify Access

SSH into the first control plane node (via Bastion) to check the cluster status:

```bash
ssh -J root@<BASTION_IP> root@10.0.1.11 kubectl get nodes
```


-----

## Production Readiness Guide

This repository deploys the **"Launchpad" Architecture**. It is designed for maximum cost-efficiency by running Workloads, Storage, and the Control Plane on the same nodes.

  * **Perfect for:** Staging, MVPs, Development, and Cost-Sensitive Startups.
  * **The Trade-off:** High disk I/O from workloads (e.g., large database imports) can impact Etcd latency, potentially causing momentary cluster instability.

### Graduation Path (The "Scale-Up")

For mission-critical production workloads, we recommend graduating to a **Split Architecture**:

1.  **Dedicated Control Plane:** 3x nodes running *only* K3s/Etcd.
2.  **Dedicated Worker Pools:** Scalable nodes for applications.
3.  **Distributed Storage:** Implementing Longhorn or Rook/Ceph for RWX volumes.

*This framework supports these patterns via configuration, but defaults to the hyper-converged model for accessibility.*

-----

## Managed Services

This repository is Open Source (MIT). You are free to use it to build your own infrastructure.

**Need a partner?**
I offer **Fixed-Price DevOps Services** for SMBs. I can deploy, manage, and monitor this stack for you, saving you the cost of a full-time DevOps engineer.

  * **Migration Assistance:** Move from AWS/Heroku/DigitalOcean to Hetzner.
  * **24/7 Monitoring:** Proactive alerts and incident response.
  * **Security Patching:** Weekly updates and CIS benchmark audits.

[**Contact Me**](mailto:michaelhenzl.em@gmail.com) | [**Book a Free Architecture Audit**]
