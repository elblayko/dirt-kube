# Dirt-Kube
Kubernetes manifests for DevJam MyDiRT application.

# Software Requirements

Required:
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Compatible driver](https://minikube.sigs.k8s.io/docs/drivers/)

Optional:
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

In absense of `kubectl`, replace all commands with `minikube kubectl`.

# Installation
Generate a self-signed TLS certificate, install on the local machine if desired.
```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout dirt.key \
    -out dirt.crt \
    -subj "/CN=dirt.af.mil/O=dirt.af.mil" \
    -addext "subjectAltName = DNS:dirt.af.mil"
```

Start the Minikube service:
```bash
minikube start
```

Create a Kubernetes TLS secret from the generated certificate.
```bash
kubectl create secret tls dirt.af.mil \
    --key dirt.key --cert dirt.crt
```

Load the MS-SQL Server schema from the *dirt-db* repo into a Kubernetes config map.  Replace `$HOME/projects/dirt-db` with the path of the Git repository.
```bash
kubectl create configmap dirt-db-files --from-file \
    schema.sql=$HOME/projects/dirt-db/schema.sql
```

Deploy the ingress controller, wait until fully deployed.
```bash
kubectl apply -f resources/
kubectl rollout status deploy -n ingress-nginx ingress-nginx-controller
```

Deploy the application:
```bash
kubectl apply -f app/
```

Create a tunnel into the cluster, as the load balancer listens on privileged ports.
```bash
minikube tunnel
```

Get the IP address of the LoadBalancer and add to operating system `hosts` file.  Note the `EXTERNAL-IP` column:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Example:
```
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.100.128.169   127.0.0.1     80:30754/TCP,443:31838/TCP   4m47s
```

The application will be accessable at `https://dirt.af.mil/`

# Maintainance

## Regenerate TLS certificates

Generate new certificates:
```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout dirt.key \
    -out dirt.crt \
    -subj "/CN=dirt.af.mil/O=dirt.af.mil" \
    -addext "subjectAltName = DNS:dirt.af.mil"
```

Delete old certificate and upload the new one:
```bash
kubectl delete secret dirt.af.mil
kubectl create secret tls dirt.af.mil --key dirt.key --cert dirt.crt
```

Restart the NGINX Ingress Controller:
```bash
kubectl -n ingress-nginx rollout restart deployment ingress-nginx-controller
```

## Change Service Passwords

In progress.