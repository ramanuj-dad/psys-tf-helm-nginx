#!/bin/bash

# Exit immediately if any command fails
set -e

# Function to exit with error message
function fail() {
  echo "❌ ERROR: $1"
  exit 1
}

echo "🚀 NGINX Ingress Deployment Started"

# Validate environment variables
[ -z "$ACTION" ] && fail "ACTION environment variable is not set"

echo "Action: $ACTION"

cd /workspace/terraform || fail "Could not change to terraform directory"

# Copy state manager script to be accessible
cp /workspace/k8s/state-manager.sh /workspace/terraform/
chmod +x /workspace/terraform/state-manager.sh

if [ "$ACTION" = "apply" ]; then
  echo "📋 Checking for existing Terraform state..."
  ./state-manager.sh load || echo "No previous state found - starting fresh deployment"
  
  echo "📋 Initializing Terraform..."
  terraform init || fail "Terraform initialization failed"
  
  echo "📋 Planning Terraform deployment..."
  terraform plan || fail "Terraform plan failed"
  
  echo "📋 Applying Terraform configuration..."
  terraform apply -auto-approve || fail "Terraform apply failed"
  
  echo "📋 Terraform deployment completed!"
  terraform output || echo "No outputs available"
  
  echo "💾 Saving Terraform state to ConfigMap for future operations..."
  ./state-manager.sh save || fail "Failed to save Terraform state to ConfigMap"
  
  echo "✅ Checking deployed resources..."
  kubectl get pods -n ingress-nginx || echo "No pods found in ingress-nginx namespace"
  kubectl get svc -n ingress-nginx || echo "No services found in ingress-nginx namespace"
  
elif [ "$ACTION" = "destroy" ]; then
  echo " Loading previous Terraform state from ConfigMap (mandatory for destroy)..."
  ./state-manager.sh load_mandatory || fail "Failed to load Terraform state - cannot destroy without state"
  
  echo "📋 Initializing Terraform..."
  terraform init || fail "Terraform initialization failed"
  
  echo "🗑️ Destroying infrastructure with Terraform..."
  terraform destroy -auto-approve || fail "Terraform destroy failed"
  
  echo "🧹 Cleaning up Terraform state ConfigMap..."
  ./state-manager.sh cleanup || echo "Warning: Failed to clean up state ConfigMap"
  
  echo "✅ Destruction completed!"
else
  fail "Unknown action: $ACTION"
fi
