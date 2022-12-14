# Dirt-Kube
Kubernetes deployment manifests for DevJam DIRT application.

### Prerequisites
Build the *dirt-app* and *dirt-api* images within their respective repos with the dirt-*:latest tag.

```bash
docker build --pull --rm -t dirt-app:latest .
docker build --pull --rm -t dirt-api:latest .
```

# Deployment

Install the NGINX Ingress Controller:
```bash
kubectl apply -f resources/nginx-ingress-1.5.1.yaml
```

Deploy the full stack:
```bash
kubectl apply -f app/
```
