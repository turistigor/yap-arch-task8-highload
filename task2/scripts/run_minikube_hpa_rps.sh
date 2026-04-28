!/bin/bash

read -p "Delete current minikube (Y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
then
    minikube delete --all
fi

minikube start --addons=metrics-server

kubectl apply -f ../k8s/rps_scale/scale-test-app-prom.yaml
echo "Wait for the deployment..."
if kubectl wait --for=condition=available deployment/scaletest-deployment -n highload --timeout=120s 2>/dev/null;
then
    echo -e "Deployment successfully created\n"
else
    echo -e "Deployment creation error\n"
    exit 1
fi

echo "Wait for the application pod..."
if kubectl wait --for=condition=ready pod --selector=app=scaletest-pod -n highload --timeout=120s 2>/dev/null;
then
    echo -e "Pod successfully created\n"
else
    echo -e "Pod creation error\n"
    exit 1
fi

echo "Wait for the application service..."
if kubectl get service scaletest-service -n highload -o jsonpath='{.spec.clusterIP}' | grep -q '^[0-9]';
then
    echo -e "Service clusterIP getting: SUCCESS\n"
else
    echo -e "Service clusterIP getting: FAILED\n"
    exit 1
fi

echo "Wait for the service endpoints ..."
if kubectl get endpoints scaletest-service -n highload -o jsonpath='{.subsets[0].addresses[0].ip}' | grep -q '^[0-9]';
then
    echo -e "Service endpoints creation: SUCCESS\n"
else
    echo -e "Service endpoints creation: FAILED\n"
    exit 1
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts > /dev/null 2>&1
helm repo update > /dev/null 2>&1
helm install prometheus prometheus-community/kube-prometheus-stack \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  > /dev/null 2>&1

echo "Wait for the prometheus pods..."
sleep 30s
if kubectl wait --for=condition=ready pod --selector prometheus=prometheus-kube-prometheus-prometheus --timeout=120s 2>/dev/null;
then
    echo -e "Pods successfully created\n"
else
    echo -e "Pods creation error\n"
    exit 1
fi

kubectl apply -f ../k8s/rps_scale/service-monitor.yaml
echo "Wait for the application metrics service monitor"
if kubectl get servicemonitor -n highload | grep -q scaletest-ser-mon;
then
    echo -e "Service monitor successfully created\n"
else
    echo -e "Service monitor  creation error\n"
    exit 1
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts > /dev/null 2>&1
helm repo update > /dev/null 2>&1
helm install prometheus-adapter prometheus-community/prometheus-adapter -f ../k8s/rps_scale/prom-adapter-config.yaml > /dev/null 2>&1

echo "Wait for the prometheus adapter pod..."
if kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=prometheus-adapter --timeout=120s 2>/dev/null;
then
    echo -e "Pod successfully created\n"
else
    echo -e "Pod creation error\n"
    exit 1
fi

if kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | \
    jq -e ".resources[] | \
    select(.name | contains(\"http_requests_per_second\"))" > /dev/null;
then
    echo -e "http_requests_per_second metric registration: SUCCESS\n"
else
    echo -e "http_requests_per_second metric registration: FAILED\n"
fi

kubectl apply -f ../k8s/rps_scale/hpa-rps.yaml

echo "Wait fot HPA..."
if kubectl wait --for=condition=abletoscale hpa scaletest-hpa -n highload --timeout=60s 2>/dev/null;
then
    echo -e "The HPA is able to scale\n"
else
    echo -e "The HPA is NOT able to scale\n"
    exit 1
fi

echo "K8s cluster is ready!"

python3 -m venv ../../.venv
source ../../.venv/bin/activate
echo "Python dependencies installation..."
if pip install -r ../../requirements.txt -q; then
    echo -e "Dependencies installation: SUCCESS\n"
else
    echo -e "Dependencies installation: FAILED\n"
    exit 1
fi

MINIKUBE_IP=$(minikube ip)
if curl -s -o /dev/null -w "%{http_code}" http://$MINIKUBE_IP:30000 | grep -q 200;
then
    echo -e "Service start: SUCCESS\n"
else
    echo -e "Service start: FAILED\n"
fi