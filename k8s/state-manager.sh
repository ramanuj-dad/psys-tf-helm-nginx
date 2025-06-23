#!/bin/bash
set -e

NAMESPACE="deployment-automation"
CONFIGMAP_NAME="terraform-state-nginx-ingress"

# Function to save state to ConfigMap
save_state() {
  echo "📦 Saving Terraform state to ConfigMap..."
  
  LOCK_HCL=$(cat .terraform.lock.hcl | base64)
  STATE_FILE=$(cat terraform.tfstate | base64)
  
  kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE --ignore-not-found=true
  kubectl create configmap $CONFIGMAP_NAME -n $NAMESPACE \
    --from-literal=timestamp="$(date)" \
    --from-literal=lock_hcl_b64="$LOCK_HCL" \
    --from-literal=state_file_b64="$STATE_FILE"
  
  echo "✅ Terraform state saved to ConfigMap: $CONFIGMAP_NAME"
}

# Function to load state from ConfigMap if it exists
load_state() {
  if kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &>/dev/null; then
    echo "📦 Loading existing Terraform state from ConfigMap..."
    
    LOCK_HCL=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.lock_hcl_b64}' | base64 -d)
    STATE_FILE=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.state_file_b64}' | base64 -d)
    
    echo "$LOCK_HCL" > .terraform.lock.hcl
    echo "$STATE_FILE" > terraform.tfstate
    
    echo "✅ Terraform state loaded from ConfigMap: $CONFIGMAP_NAME"
    return 0
  else
    echo "ℹ️ No previous Terraform state found - starting fresh"
    return 1
  fi
}

# Function to load state from ConfigMap (mandatory for destroy)
load_state_mandatory() {
  if ! kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &>/dev/null; then
    echo "❌ ERROR: No Terraform state ConfigMap found. Cannot perform destroy operation without state."
    exit 1
  fi
  
  echo "� Loading Terraform state from ConfigMap..."
  LOCK_HCL=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.lock_hcl_b64}' | base64 -d)
  STATE_FILE=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.state_file_b64}' | base64 -d)
  
  echo "$LOCK_HCL" > .terraform.lock.hcl
  echo "$STATE_FILE" > terraform.tfstate
  
  echo "✅ Terraform state loaded from ConfigMap: $CONFIGMAP_NAME"
}

# Function to clean up state ConfigMap
cleanup_state() {
  echo "🧹 Cleaning up Terraform state ConfigMap..."
  kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE --ignore-not-found=true
  echo "✅ Terraform state ConfigMap removed"
}

# Execute the appropriate function based on argument
case "$1" in
  "save")
    save_state
    ;;
  "load")
    load_state
    ;;
  "load_mandatory")
    load_state_mandatory
    ;;
  "cleanup")
    cleanup_state
    ;;
  *)
    echo "Usage: $0 [save|load|load_mandatory|cleanup]"
    exit 1
    ;;
esac
