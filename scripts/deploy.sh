#!/bin/bash
set -e

echo "--- Step 1: Infrastructure (Terraform) ---"
cd infrastructure/hetzner

# Handle Remote State (Optional)
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo "🔒 S3 Credentials detected."
    if [ ! -f "backend.tf" ]; then
        cp backend.tf.example backend.tf
        echo "✅ Enabled S3 Backend."
    fi
else
    echo "⚠️  No S3 Credentials. Using Local State."
fi

terraform init
terraform apply -auto-approve
cd ../..

echo "--- Step 2: Inventory Generation ---"
python3 scripts/glue.py

echo "--- Step 3: Configuration (Ansible) ---"
cd automation
ansible-playbook site.yml
