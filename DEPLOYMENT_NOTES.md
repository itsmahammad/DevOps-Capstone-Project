# Deployment baseline notes

This repo now contains a baseline implementation for a production AKS deployment targeting Germany West Central with:

- NGINX ingress
- Azure Container Registry only
- Azure SQL for the production data layer
- GitHub Actions OIDC-based Azure auth
- Separate frontend and backend deployment workflows
- Single production environment only

## Important implementation notes

1. The Kubernetes manifests assume the image names will be injected by GitHub Actions.
2. The Terraform plan is intentionally baseline-oriented and should be reviewed before first apply.
3. Private endpoint and Key Vault integration should be hardened further before real production rollout.
4. The ingress host should be changed from app.example.com to the real DNS name before use.
5. The repo should use GitHub environment protection rules and required reviewers for the production environment.
