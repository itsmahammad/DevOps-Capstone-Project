# Deployment Notes — Resume-ATS Production

## Current Status: Complete

All infrastructure, CI/CD, Kubernetes, observability, and security components are implemented.

## What Was Changed (from the original baseline)

### Phase 1 — Local Dev & Containers
- **Backend Dockerfile:** Rewrote as multi-stage build. Added `tesseract-ocr`, `poppler-utils`, `libgl1`, `libglib2.0-0` to the runtime stage (required for OCR fallback). Build tools (`gcc`, `g++`, `libffi-dev`, `libssl-dev`, `pkg-config`) in the builder stage for PyMuPDF/pypdf/Pillow.
- **Frontend Dockerfile:** Rewrote to use Next.js standalone output mode. `next.config.js` updated with `output: 'standalone'` — produces a much slimmer image (no full `node_modules` copy).
- **docker-compose.yml:** Created — wires frontend + backend with health checks and proper networking.
- **.env.example:** Created — documents all env vars for local dev and CI/CD.
- **.dockerignore:** Improved for both frontend and backend.

### Phase 2 — Infrastructure (Terraform)
- **Naming conventions fixed:** `project_name` default changed from `devops-capstone` to `resumeats` → produces `rg-resumeats-prod`, `aks-resumeats-prod`, `acrresumeatsprod`.
- **AKS module:** System pool autoscaler enabled (min 1/max 2). User pool changed to `Standard_B2ms` (was `Standard_B2s`) for OCR memory headroom.
- **SQL module:** Changed from `Basic` SKU to serverless `GP_S_Gen5` (1 vCore, auto-pause 60 min). Added `max_size_gb`, `auto_pause_delay_in_minutes`, `min_capacity` variables.
- **backend.tf:** State key changed from `prod.terraform.tfstate` to `production/terraform.tfstate`.
- **github-oidc module:** Created — Azure AD App Registration + Service Principal + federated identity credentials for GitHub Actions OIDC. Grants Contributor on RG + AcrPush on ACR.
- **providers.tf:** Added `azuread` provider.
- **outputs.tf:** Added `github_oidc_client_id` and `github_oidc_tenant_id` outputs.
- **resource-group module:** Added `id` output.

### Phase 3 — GitHub Actions (Infra)
- **terraform.yml** (combined) → split into **infra-plan.yml** (PR: fmt, validate, plan, post as PR comment) and **infra-apply.yml** (main: apply with approval gate).
- Both use OIDC with `ARM_USE_OIDC: true` — no static credentials.

### Phase 4 — Kubernetes Platform (Helm)
- **k8s/helm/frontend/** and **k8s/helm/backend/** Helm charts created with:
  - Deployment (rolling update `maxUnavailable: 1`, ≥3 replicas in production)
  - Service (backend is ClusterIP only, no ingress)
  - HPA (CPU-based, min 3 in production)
  - PDB (minAvailable: 1)
  - Ingress (frontend only, with cert-manager TLS annotation)
  - ConfigMap, SecretProviderClass, NetworkPolicy, ServiceAccount, RBAC
- **Backend resources:** 500m/512Mi requests, 2000m/2Gi limits (OCR headroom)
- **Backend NetworkPolicy:** Only allows ingress from frontend pods
- **k8s/platform/**: namespace.yaml, cluster-issuer.yaml (Let's Encrypt), README.md with install guide

### Phase 5 — CI/CD (App Pipelines)
- **frontend.yml** and **backend.yml** (combined) → split into 4 separate workflows:
  - `frontend-ci.yml` (PR: build, lint, Trivy scan)
  - `frontend-cd.yml` (main: build, push ACR, Trivy scan, helm deploy, rollout status)
  - `backend-ci.yml` (PR: test, build, Trivy scan)
  - `backend-cd.yml` (main: build, push ACR, Trivy scan, helm deploy, rollout status)
- All CD workflows use `environment: production` (approval gate), OIDC auth, git SHA tagging, `kubectl rollout status` check.

### Phase 6 — Observability
- **monitoring/kube-prometheus-stack/values-production.yaml:** Prometheus, Alertmanager, Grafana config with additional scrape configs and PrometheusRule alerts.
- **3 Grafana dashboards:** API latency/errors, request rate/saturation, cluster node/pod health.
- **Alert rules:** HighErrorRate, ElevatedLatency, CrashLoopBackOff, PodUnschedulable, HighNodeCPU, HighNodeMemory.

### Phase 7 — Security Hardening
- RBAC Role/RoleBinding templates added to both Helm charts (least-privilege: get/list/watch on pods/configmaps only).
- NetworkPolicies: backend only reachable from frontend pods.
- SecretProviderClass templates ready for Key Vault CSI driver.
- Trivy image scanning in both CI and CD pipelines (blocks on CRITICAL/HIGH).
- No `:latest` tags — all images tagged with git commit SHA.

### Phase 8 — Load Testing & Docs
- **loadtest/k6-script.js:** k6 script targeting ≥300 req/s at p95 ≤ 300ms for `/health`, with `/api/analyze` testing using text-based PDFs (not scanned, to avoid slow OCR).
- **RUNBOOK.md:** Deployment, rollback, secret rotation, scaling, incident response, alert runbook entries.
- **ARCHITECTURE.md:** Mermaid diagram + justifications for NGINX, ACR, OIDC, node pool design, single-env trade-off, SQL-unused call-out.
- **README.md:** Extended with DevOps setup summary and quick start guide.

## Flagged Open Items

1. **Azure SQL is provisioned but not used by the app.** The app is stateless (`POST /api/analyze` processes in-memory). SQL is provisioned per the rubric requirement. Connecting it would require modifying `backend/app/`, which is off-limits. See `ARCHITECTURE.md` for details.

2. **Single production environment (no staging).** Deliberate trade-off for time. The GitHub `production` environment with required reviewers satisfies "protected approvals." See `ARCHITECTURE.md` for justification.

3. **Ingress host is `app.example.com`.** Change to the real DNS name before production deployment in `k8s/helm/frontend/values-production.yaml`.

4. **ClusterIssuer email is `admin@example.com`.** Change to a real email in `k8s/platform/cluster-issuer.yaml`.

5. **Grafana admin password is empty.** Set via `--set grafana.adminPassword=...` during Helm install.

## Before First Deployment

1. Apply `infra/terraform/bootstrap` manually (one-time) to create the remote state storage account.
2. Copy bootstrap outputs into `infra/terraform/backend.tf`.
3. Create `infra/terraform/terraform.tfvars` with real `tenant_id`.
4. Run `terraform plan` and review, then `terraform apply`.
5. Copy Terraform outputs (`github_oidc_client_id`, `github_oidc_tenant_id`) into GitHub secrets.
6. Set GitHub variables: `ACR_NAME`, `ACR_LOGIN_SERVER`, `AKS_RESOURCE_GROUP`, `AKS_CLUSTER_NAME`.
7. Protect the `production` GitHub environment with required reviewers.
8. Install platform components (ingress-nginx, cert-manager, CSI driver) per `k8s/platform/README.md`.
9. Change `app.example.com` to the real DNS name and `admin@example.com` to a real email.