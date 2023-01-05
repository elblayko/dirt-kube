#!/bin/sh
DEFAULT_MSSQL_PASSWORD="Passw0rd?"

if [ ! -x "$(command -v minikube)" ]; then
    echo "Minikube not found. Please install minikube and try again."
    exit 1
fi;

if [ ! -x "$(command -v openssl)" ]; then
    echo "OpenSSL not found. Please install OpenSSL and try again."
    exit 1
fi;

if [ ! -x "$(command -v kubectl)" ]; then
    echo "Kubectl not found. Setting kubectl alias to minikube kubectl."
    alias kubectl='minikube kubectl --'
fi;

echo "✨ Starting minikube..."
minikube start

echo "✨ Creating TLS certificate for DIRT..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout dirt.key \
    -out dirt.crt \
    -subj "/CN=dirt.af.mil/O=dirt.af.mil" \
    -addext "subjectAltName = DNS:dirt.af.mil"

echo "✨ Creating secret for DIRT TLS certificate..."
kubectl create secret tls dirt.af.mil --key dirt.key --cert dirt.crt

echo "✨ Creating configmap for DIRT database schema..."
kubectl create configmap dirt-db-config \
    --from-literal schema="$(curl -s https://raw.githubusercontent.com/elblayko/dirt-db/master/schema.sql)" \
    --from-literal accept-eula="Y"

echo "✨ Deploying Ingress controller... (about a minute)"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
kubectl rollout status deployment -n ingress-nginx ingress-nginx-controller

echo "✨ Deploying DIRT... (about 2 minutes)"
kubectl apply -f https://raw.githubusercontent.com/elblayko/dirt-kube/master/app/api.yml
kubectl apply -f https://raw.githubusercontent.com/elblayko/dirt-kube/master/app/app.yml
kubectl apply -f https://raw.githubusercontent.com/elblayko/dirt-kube/master/app/db.yml
kubectl apply -f https://raw.githubusercontent.com/elblayko/dirt-kube/master/app/ingress.yml
kubectl rollout status deployment dirt-api
kubectl rollout status deployment dirt-app
kubectl rollout status statefulset dirt-db

echo "✨ Sleeping for 30 seconds to allow SQL server to fully start..."
sleep 30

echo "✨ Importing DIRT database schema..."
kubectl exec -i statefulset/dirt-db -- bash -c "/opt/mssql-tools/bin/sqlcmd -U sa -i /var/opt/mssql/schema/schema.sql -P $DEFAULT_MSSQL_PASSWORD"

if [ "$1" = 'dev' ]; then
    echo "Inserting dummy data..."
    kubectl exec -i deployment/dirt-api -- bash -c "perl script/insert_dummy"
fi;

echo "🎉 Done!"

cat << EOF
Next steps:
    1. Get the IP address of the Ingress controller, note the external IP address:
        kubectl get svc -n ingress-nginx ingress-nginx-controller
    2. Add the IP address to your hosts file:
        echo "<EXTERNAL_IP_ADDRESS> dirt.af.mil" | sudo tee -a /etc/hosts
    3. Run "minikube tunnel" in a separate terminal window.
    4. Open https://dirt.af.mil in your browser.

    If EXTERNAL IP is not available, try running:
        minikube tunnel
EOF