# Platform components installation guide

## 1. Install ingress-nginx (official Helm chart)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

## 2. Install cert-manager (official Helm chart)
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

## 3. Apply the ClusterIssuer
kubectl apply -f k8s/platform/cluster-issuer.yaml

## 4. Create the production namespace
kubectl apply -f k8s/platform/namespace.yaml

## 5. Install Key Vault CSI Secret Store driver
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure
helm repo update
helm install csi-secrets-store-provider-azure csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
  --namespace kube-system

## 6. Deploy frontend and backend Helm charts
helm upgrade --install frontend ./k8s/helm/frontend \
  --namespace resumeats-prod \
  -f k8s/helm/frontend/values-production.yaml \
  --set image.repository=<ACR_LOGIN_SERVER>/frontend \
  --set image.tag=<GIT_SHA>

helm upgrade --install backend ./k8s/helm/backend \
  --namespace resumeats-prod \
  -f k8s/helm/backend/values-production.yaml \
  --set image.repository=<ACR_LOGIN_SERVER>/backend \
  --set image.tag=<GIT_SHA>
