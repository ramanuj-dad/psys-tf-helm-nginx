#!/bin/bash

# Setup script for creating the deployment ConfigMap
# Run this script on your Kubernetes cluster before using the GitHub Actions workflow

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 NGINX Ingress Controller Deployer Setup${NC}"
echo "=============================================="
echo

# Get cluster IP
while true; do
    read -p "Enter your Kubernetes cluster IP address: " cluster_ip
    if [[ $cluster_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}❌ Invalid IP address format. Please try again.${NC}"
    fi
done

echo -e "${BLUE}📋 Creating namespace and ConfigMap...${NC}"

# Create namespace
kubectl create namespace deployment-automation --dry-run=client -o yaml | kubectl apply -f -

# Create ConfigMap with cluster IP
kubectl create configmap deployment-config \
    --from-literal=cluster_ip=$cluster_ip \
    --namespace=deployment-automation \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Configure GitHub Secrets in your repository:"
echo -e "   ${YELLOW}TARGET_HOST${NC}=$cluster_ip"
echo -e "   ${YELLOW}TARGET_USER${NC}=your-ssh-username"
echo -e "   ${YELLOW}SSH_PRIVATE_KEY${NC}=your-ssh-private-key"
echo -e "   ${YELLOW}SSH_KNOWN_HOSTS${NC}=$(ssh-keyscan -H $cluster_ip 2>/dev/null)"
echo
echo "2. Push code to main branch or manually trigger the workflow"
echo "3. Watch the magic happen! 🎉"
echo
echo -e "${GREEN}🔗 Your NGINX Ingress will be available at:${NC}"
echo -e "   ${YELLOW}http://$cluster_ip/${NC}"
echo -e "   ${YELLOW}https://$cluster_ip/${NC}"
