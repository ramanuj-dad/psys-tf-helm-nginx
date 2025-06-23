#!/bin/bash
# Release preparation script for NGINX Ingress Controller Deployment

set -e

echo "🚀 Preparing release for NGINX Ingress Controller Deployment"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ This script must be run from the root of the git repository"
    exit 1
fi

# Get current versions from Terraform variables
CHART_VERSION=$(grep -A3 "nginx_ingress_chart_version" terraform/variables.tf | grep default | sed 's/.*"\(.*\)".*/\1/')
APP_VERSION=$(grep -A3 "nginx_ingress_app_version" terraform/variables.tf | grep default | sed 's/.*"\(.*\)".*/\1/')
IMAGE_TAG=$(grep -A3 "nginx_ingress_controller_image_tag" terraform/variables.tf | grep default | sed 's/.*"\(.*\)".*/\1/')

echo "📋 Current component versions:"
echo "  Chart Version: $CHART_VERSION"
echo "  App Version: $APP_VERSION"
echo "  Image Tag: $IMAGE_TAG"

# Suggest release version based on chart version
RELEASE_VERSION="v$CHART_VERSION"
echo "💡 Suggested release version: $RELEASE_VERSION"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  There are uncommitted changes. Please commit them first."
    git status --short
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Not on main/master branch. Current branch: $CURRENT_BRANCH"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create release notes template
RELEASE_NOTES="RELEASE_NOTES_$RELEASE_VERSION.md"
cat > "$RELEASE_NOTES" << EOF
# Release $RELEASE_VERSION

## NGINX Ingress Controller Deployment

### Component Versions
- **NGINX Ingress Helm Chart**: $CHART_VERSION
- **NGINX Ingress Controller**: $APP_VERSION
- **Controller Image Tag**: $IMAGE_TAG

### Features
- ✅ Automated deployment via GitHub Actions
- ✅ Kubernetes-native state management using ConfigMap
- ✅ Temporary admin service account with automatic cleanup
- ✅ Version-pinned components for reproducible deployments
- ✅ Support for both apply and destroy operations
- ✅ NodePort service with configurable ports (30080/30443)

### Security Enhancements
- 🔒 Temporary service accounts created and removed per deployment
- 🔒 No persistent elevated privileges
- 🔒 Containerized deployment job with minimal required permissions
- 🔒 State stored securely in Kubernetes ConfigMap

### Infrastructure as Code
- 📝 Terraform-managed infrastructure
- 📝 Version-controlled configuration
- 📝 Idempotent deployments
- 📝 Clean destroy operations

### Documentation
- 📚 Comprehensive README with setup instructions
- 📚 Version management guidelines in VERSIONS.md
- 📚 Terraform variable examples and configuration

### Usage
1. Fork this repository
2. Add KUBE_CONFIG secret to your repository
3. Run the "Deploy NGINX Ingress Controller" GitHub Actions workflow
4. Choose "apply" to deploy or "destroy" to remove

### Compatibility
- **Kubernetes**: >= 1.21.0
- **Terraform**: >= 1.0
- **Helm**: 3.x (via Terraform provider)

### What's New in This Release
- [ ] Add specific changes for this release here

### Breaking Changes
- [ ] List any breaking changes here

### Known Issues
- [ ] List any known issues here

### Upgrade Instructions
- [ ] Add upgrade instructions if applicable
EOF

echo "📝 Created release notes template: $RELEASE_NOTES"
echo "✏️  Please edit the release notes and then run:"
echo ""
echo "  git add ."
echo "  git commit -m \"Prepare release $RELEASE_VERSION\""
echo "  git tag -a $RELEASE_VERSION -m \"Release $RELEASE_VERSION\""
echo "  git push origin $CURRENT_BRANCH"
echo "  git push origin $RELEASE_VERSION"
echo ""
echo "🎯 Then create a GitHub release using the release notes in $RELEASE_NOTES"

echo "✅ Release preparation completed!"
