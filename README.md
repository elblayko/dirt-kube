[![CI](https://github.com/elblayko/dirt-kube/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/elblayko/dirt-kube/actions/workflows/ci.yml)

# Dirt-Kube
Kubernetes manifests for DevJam MyDiRT application.

# Software Requirements

Required:
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Compatible driver](https://minikube.sigs.k8s.io/docs/drivers/)

Optional:
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

In absense of `kubectl`, replace all commands with `minikube kubectl`.

# TL;DR

Without dummy data:
```bash
curl -sfL https://raw.githubusercontent.com/elblayko/dirt-kube/master/minikube-deploy.sh | sh -
```

With dummy data:
```bash
curl -sfL https://raw.githubusercontent.com/elblayko/dirt-kube/master/minikube-deploy.sh | sh -
curl -sfL https://raw.githubusercontent.com/elblayko/dirt-kube/master/minikube-deploy.sh | sh -s -- --with-dummy-data --no-tls
```

The application will be accessable at `https://dirt.af.mil/`, the default database credentials are: `sa`, `Passw0rd?`

# Maintainance

## Regenerate TLS certificates

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout dirt.key \
    -out dirt.crt \
    -subj "/CN=dirt.af.mil/O=dirt.af.mil" \
    -addext "subjectAltName = DNS:dirt.af.mil"

kubectl delete secret dirt.af.mil
kubectl create secret tls dirt.af.mil --key dirt.key --cert dirt.crt

kubectl -n ingress-nginx rollout restart deployment ingress-nginx-controller
```

## Change Service Passwords

In progress.
