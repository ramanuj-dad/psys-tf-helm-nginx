# NGINX Ingress Controller - Containerized Terraform Deployment

A clean, efficient automation solution for deploying NGINX Ingress Controller using Terraform with Helm provider in a containerized approach on Kubernetes.

## 🎯 **Core Principles**

- **Simplicity**: Minimal configuration, maximum automation
- **Reliability**: Idempotent deployments with proper error handling  
- **Efficiency**: Containerized execution keeps servers clean
- **Security**: Kubernetes-native RBAC and process isolation

## 🏗️ **Architecture**

```
GitHub Actions → Container Image → Kubernetes Job → Terraform + Helm → NGINX Ingress
```

**Key Benefits:**
- ✅ **Zero server pollution** - No tools installed on target server
- ✅ **Full isolation** - Everything runs in containers
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Kubernetes-native** - Leverages existing cluster infrastructure

## 📁 **Project Structure**

```
.
├── .github/workflows/
│   └── deploy.yaml                 # CI/CD pipeline
├── docker/
│   ├── Dockerfile                  # Deployment container
│   └── entrypoint.sh              # Container logic
├── terraform/
│   ├── main.tf                     # NGINX Ingress deployment
│   ├── variables.tf               # Configuration variables
│   └── outputs.tf                 # Deployment outputs
├── helm/
│   └── values.yaml                # Helm values for bare-metal
├── k8s/
│   └── deployment-job.yaml        # Kubernetes Job manifests
├── scripts/
│   ├── build-image.sh             # Build deployment container
│   ├── deploy.sh                  # Local deployment script
│   ├── create-configmaps.sh       # Setup ConfigMaps
│   └── test.sh                    # Integration tests
├── examples/
│   ├── sample-app.yaml            # Test application
│   └── README.md                  # Usage examples
└── README.md                      # This file
```

## 🚀 **Quick Start**

### Prerequisites
- Kubernetes cluster running (your CentOS VM with kubeadm)
- kubectl configured and connected
- Docker available for building images

### 1. Build Deployment Container
```bash
./scripts/build-image.sh
```

### 2. Deploy NGINX Ingress Controller
```bash
# Plan deployment (safe check)
./scripts/deploy.sh plan

# Apply deployment  
./scripts/deploy.sh apply

# Test deployment
./scripts/deploy.sh test
```

### 3. Verify Deployment
```bash
# Check NGINX Ingress status
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# Deploy test application
kubectl apply -f examples/sample-app.yaml

# Test access
curl -H "Host: demo.local" http://192.168.122.157/
```

## 🔧 **Configuration**

### Environment Variables
Edit `terraform/variables.tf` for customization:
```hcl
variable "nginx_ingress_version" {
  default = "4.8.3"  # Helm chart version
}

variable "cluster_ip" {
  default = "192.168.122.157"  # Your server IP
}
```

### Helm Values
The `helm/values.yaml` is optimized for bare-metal single-node clusters:
- DaemonSet mode for bare-metal
- Host ports enabled (80/443)
- Control-plane tolerations
- NodePort service configuration

## 🐳 **Container Details**

The deployment container includes:
- **Terraform** v1.6.6
- **Helm** v3.13.3
- **kubectl** (latest)
- **Alpine Linux** (minimal footprint)

**Security Features:**
- Non-root execution (user: runner)
- Resource limits (CPU: 500m, Memory: 512Mi)
- Read-only configuration mounts
- Kubernetes RBAC integration

## 🔄 **CI/CD Pipeline**

### GitHub Actions Workflow
Trigger via:
- **Manual**: Repository Actions tab → Run workflow
- **Automatic**: Push to main branch

### Workflow Steps:
1. **Validate** - Terraform and Helm syntax checks
2. **Build** - Create deployment container image
3. **Deploy** - Execute via Kubernetes Job
4. **Test** - Run integration tests
5. **Cleanup** - Remove completed jobs

### Required Secrets:
- `SSH_PRIVATE_KEY` - SSH key for server access
- `SSH_KNOWN_HOSTS` - SSH known hosts entry

## 📊 **Monitoring**

### View Deployment Logs:
```bash
kubectl logs -f job/nginx-ingress-deployment-apply -n deployment-automation
```

### Check Job Status:
```bash
kubectl get jobs -n deployment-automation
kubectl get pods -n deployment-automation
```

### Monitor NGINX Ingress:
```bash
kubectl get pods -n ingress-nginx -w
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f
```

## 🔍 **Troubleshooting**

### Common Issues:

1. **Job Fails to Start**
   ```bash
   kubectl describe job nginx-ingress-deployment-apply -n deployment-automation
   kubectl get events -n deployment-automation
   ```

2. **Image Pull Errors**
   ```bash
   ./scripts/build-image.sh  # Rebuild and reload image
   ```

3. **Permission Errors**
   ```bash
   kubectl get clusterrolebinding terraform-deployer
   kubectl describe sa terraform-deployer -n deployment-automation
   ```

4. **Terraform Errors**
   ```bash
   # Check ConfigMaps
   kubectl get configmaps -n deployment-automation
   kubectl describe configmap terraform-config -n deployment-automation
   ```

## 🧪 **Testing**

### Automated Tests:
```bash
./scripts/test.sh  # Run full test suite
```

### Manual Verification:
```bash
# Deploy sample application
kubectl apply -f examples/sample-app.yaml

# Test ingress functionality
curl -H "Host: demo.local" http://192.168.122.157/
curl -H "Host: demo.local" http://192.168.122.157/api/health
```

## 🔧 **Advanced Usage**

### Custom Deployment:
```bash
# Deploy with specific action
./scripts/deploy.sh plan    # Plan only
./scripts/deploy.sh apply   # Apply changes  
./scripts/deploy.sh destroy # Remove deployment
```

### Update Configuration:
```bash
# Modify terraform/variables.tf or helm/values.yaml
# Then rebuild and redeploy
./scripts/build-image.sh
./scripts/deploy.sh apply
```

### Parallel Deployments:
```bash
# Different job names for parallel execution
kubectl create job nginx-deployment-staging --from=cronjob/nginx-ingress-deployment
```

## 🧹 **Cleanup**

### Remove NGINX Ingress Controller:
```bash
./scripts/deploy.sh destroy
```

### Remove All Deployment Resources:
```bash
kubectl delete namespace deployment-automation
kubectl delete namespace ingress-nginx
```

### Cleanup Container Images:
```bash
docker rmi psys-terraform-deployer:latest
sudo ctr -n k8s.io images rm psys-terraform-deployer:latest
```

## 📝 **Access Information**

Once deployed, access NGINX Ingress Controller via:

| Method | URL | Description |
|--------|-----|-------------|
| **HTTP** | `http://192.168.122.157/` | Direct access via host port |
| **HTTPS** | `https://192.168.122.157/` | Secure access via host port |
| **NodePort HTTP** | `http://192.168.122.157:30080/` | NodePort service access |
| **NodePort HTTPS** | `https://192.168.122.157:30443/` | Secure NodePort access |

## 🚀 **Production Ready**

This solution is production-ready with:
- ✅ **Idempotent operations** - Safe to run repeatedly
- ✅ **Error handling** - Comprehensive error detection and reporting
- ✅ **Resource management** - Proper CPU/memory limits
- ✅ **Security** - Non-root containers, RBAC, isolation
- ✅ **Monitoring** - Detailed logging and status reporting
- ✅ **Cleanup** - Automatic job TTL and manual cleanup options

## 📞 **Support**

For issues:
1. Check the troubleshooting section
2. Review job logs: `kubectl logs job/nginx-ingress-deployment-apply -n deployment-automation`
3. Validate configuration: `kubectl describe job nginx-ingress-deployment-apply -n deployment-automation`

---

**This containerized approach provides a clean, efficient, and reliable way to deploy NGINX Ingress Controller while keeping your server pristine!** 🎉
