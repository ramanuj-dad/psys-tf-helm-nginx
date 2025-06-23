# Version Management

This document tracks the versions of components used in this NGINX Ingress Controller deployment.

## Current Versions

| Component | Version | Source |
|-----------|---------|--------|
| Helm Chart | 4.12.3 | [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/releases) |
| App Version | 1.12.3 | [NGINX Ingress Controller](https://github.com/kubernetes/ingress-nginx/releases) |
| Controller Image | v1.12.3 | [Container Registry](https://github.com/kubernetes/ingress-nginx/pkgs/container/ingress-nginx%2Fcontroller) |

## Terraform Providers

| Provider | Version Constraint | Reason |
|----------|-------------------|--------|
| kubernetes | ~> 2.0 | Stable API compatibility |
| helm | ~> 2.0 | Stable Helm 3 support |

## Version Update Strategy

### Before Updating Versions:

1. **Check Release Notes**: Review the [NGINX Ingress Controller releases](https://github.com/kubernetes/ingress-nginx/releases) for breaking changes
2. **Test in Non-Production**: Always test version updates in a development environment first
3. **Update All Three Components**: Ensure chart version, app version, and image tag are compatible
4. **Update This Document**: Keep this file current with the new versions

### Version Compatibility:

- **Chart Version**: Must be compatible with your Kubernetes version (check `kubeVersion` in Chart.yaml)
- **App Version**: Should match the chart's `appVersion` field
- **Image Tag**: Should match the app version (usually prefixed with `v`)

### Finding Compatible Versions:

1. Visit the [Chart.yaml](https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/charts/ingress-nginx/Chart.yaml)
2. Note the `version` (chart version) and `appVersion` fields
3. The image tag usually matches `appVersion` with a `v` prefix

## Configuration

To override versions, create a `terraform.tfvars` file:

```hcl
nginx_ingress_chart_version = "4.12.3"
nginx_ingress_app_version = "1.12.3"
nginx_ingress_controller_image_tag = "v1.12.3"
```

## Rollback Strategy

If a version update causes issues:

1. **Immediate Rollback**: Update variables to previous working versions
2. **Run Destroy**: `terraform destroy` to remove the problematic version
3. **Run Apply**: `terraform apply` to deploy the previous working version
4. **State Recovery**: The ConfigMap state management ensures clean rollbacks

## Security Updates

Monitor these sources for security updates:

- [NGINX Ingress Security Advisories](https://github.com/kubernetes/ingress-nginx/security/advisories)
- [CVE Database](https://cve.mitre.org/)
- [Kubernetes Security Announcements](https://kubernetes.io/docs/reference/issues-security/)

## Automated Updates

This project uses pinned versions to ensure reproducibility. Consider setting up:

- **Dependabot**: For automated dependency updates
- **Scheduled Testing**: Regular validation of new versions
- **Security Scanning**: Automated vulnerability detection
