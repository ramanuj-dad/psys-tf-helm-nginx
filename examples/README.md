# Sample Applications

Simple examples to test your NGINX Ingress Controller deployment.

## Deploy Sample App

```bash
kubectl apply -f sample-app.yaml
```

## Test Access

```bash
# Add to /etc/hosts
echo "YOUR_CLUSTER_IP demo.local" | sudo tee -a /etc/hosts

# Test access
curl http://demo.local/
curl http://demo.local/api/health
```

## Cleanup

```bash
kubectl delete -f sample-app.yaml
```
