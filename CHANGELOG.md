# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Version management system with pinned component versions
- Comprehensive Terraform outputs showing all deployed versions
- Release preparation scripts and templates
- Version compatibility documentation

### Changed
- Terraform configuration now uses variables for all version specifications
- Enhanced outputs to show chart version, app version, and image tag
- Improved documentation with version management guidelines

### Fixed
- Terraform state management for idempotent deployments
- Proper namespace lifecycle management

## [v4.12.3] - 2025-06-23

### Added
- Initial release with NGINX Ingress Controller v1.12.3
- Automated GitHub Actions workflow for deployment
- Kubernetes-native state management using ConfigMap
- Temporary admin service account with automatic cleanup
- Terraform-based infrastructure as code
- Support for both apply and destroy operations
- NodePort service configuration with ports 30080/30443

### Security
- Temporary service accounts created and removed per deployment
- No persistent elevated privileges
- Containerized deployment job with minimal required permissions
- State stored securely in Kubernetes ConfigMap

### Documentation
- Comprehensive README with setup instructions
- Terraform variable examples and configuration templates
- Security and architecture documentation

[Unreleased]: https://github.com/yourusername/psys-tf-helm-nginx/compare/v4.12.3...HEAD
[v4.12.3]: https://github.com/yourusername/psys-tf-helm-nginx/releases/tag/v4.12.3
