#!/bin/bash
set -e

NAMESPACE="deployment-automation"
CONFIGMAP_NAME="terraform-state-nginx-ingress"

# Function to save state to ConfigMap
save_state() {
  echo "📦 Saving Terraform state to ConfigMap..."
  
  # Check if state files exist
  if [ ! -f .terraform.lock.hcl ] || [ ! -f terraform.tfstate ]; then
    echo "❌ ERROR: Terraform state files not found"
    exit 1
  fi
  
  # Create ConfigMap with state files - use correct base64 flags for Alpine
  # Alpine's busybox base64 doesn't support -w flag, so we encode without wrapping
  LOCK_HCL=$(cat .terraform.lock.hcl | base64)
  STATE_FILE=$(cat terraform.tfstate | base64)
  
  # Delete previous ConfigMap if it exists
  kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE --ignore-not-found=true
  
  # Create new ConfigMap with state files
  kubectl create configmap $CONFIGMAP_NAME -n $NAMESPACE \
    --from-literal=timestamp="$(date)" \
    --from-literal=lock_hcl_b64="$LOCK_HCL" \
    --from-literal=state_file_b64="$STATE_FILE"
  
  # Verify ConfigMap was created
  if ! kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &>/dev/null; then
    echo "❌ ERROR: Failed to create state ConfigMap"
    exit 1
  fi
    
  echo "✅ Terraform state saved to ConfigMap: $CONFIGMAP_NAME"
}

# Function to load state from ConfigMap
load_state() {
  echo "📦 Loading Terraform state from ConfigMap..."
  
  # Check if ConfigMap exists
  if ! kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &>/dev/null; then
    echo "❌ ERROR: No Terraform state ConfigMap found. Cannot perform destroy operation without state."
    echo "Please run 'apply' first or manually recreate resources before trying to destroy them."
    exit 1
  fi
  
  # Extract state files from ConfigMap
  # Use -d for Alpine's busybox base64 decode
  LOCK_HCL=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.lock_hcl_b64}' | base64 -d)
  STATE_FILE=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.state_file_b64}' | base64 -d)
  
  # Check if decoding was successful
  if [ -z "$LOCK_HCL" ] || [ -z "$STATE_FILE" ]; then
    echo "❌ ERROR: Failed to decode state files from ConfigMap"
    exit 1
  fi

  # Write the state files
  echo "$LOCK_HCL" > .terraform.lock.hcl
  echo "$STATE_FILE" > terraform.tfstate
  
  # Verify files were created
  if [ ! -s .terraform.lock.hcl ] || [ ! -s terraform.tfstate ]; then
    echo "❌ ERROR: Failed to write state files"
    exit 1
  fi
  
  echo "✅ Terraform state loaded from ConfigMap: $CONFIGMAP_NAME"
}

# Function to clean up state ConfigMap
cleanup_state() {
  echo "🧹 Cleaning up Terraform state ConfigMap..."
  kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE --ignore-not-found=true
  echo "✅ Terraform state ConfigMap removed"
}

# Function to check if state exists in ConfigMap
check_state() {
  echo "🔍 Checking if Terraform state exists in ConfigMap..."
  
  if kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &>/dev/null; then
    echo "✅ Terraform state ConfigMap found: $CONFIGMAP_NAME"
    echo "Timestamp: $(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.timestamp}')"
    echo "Contains lock file: $(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.lock_hcl_b64}' | wc -c) bytes"
    echo "Contains state file: $(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.state_file_b64}' | wc -c) bytes"
    return 0
  else
    echo "❌ No Terraform state ConfigMap found"
    return 1
  fi
}

# Display usage if no argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 [save|load|cleanup|check]"
  exit 1
fi

# Execute the appropriate function based on argument
case "$1" in
  "save")
    save_state
    ;;
  "load")
    load_state
    ;;
  "cleanup")
    cleanup_state
    ;;
  "check")
    check_state
    ;;
  *)
    echo "Invalid argument: $1. Use 'save', 'load', 'cleanup', or 'check'"
    exit 1
    ;;
esac
