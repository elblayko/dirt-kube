# Dirt-Kube
Kubernetes deployment manifests for DevJam DIRT application.

### Prerequisites
Build the *dirt-app* and *dirt-api* images within their respective repos with the dirt-*:latest tag.

```bash
docker build --pull --rm -t dirt-app:latest .
docker build --pull --rm -t dirt-api:latest .
```

Generate a self-signed certificate.
```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout dirt.key \
    -out dirt.crt \
    -subj "/CN=dirt.af.mil/O=dirt.af.mil" \
    -addext "subjectAltName = DNS:dirt.af.mil"
```

Create a Kubernetes TLS secret from the generated certificates, install on the local machine if desired.
```bash
kubectl create secret tls dirt.af.mil --key dirt.key --cert dirt.crt
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
