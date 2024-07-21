#!/bin/bash

# Set variables
NAMESPACE="udacity"
DEPLOYMENT_NAME="green"
CONFIG_MAP_NAME="green-config"
SERVICE_NAME="green-svc"
TIMEOUT=300

# Apply the green deployment configuration
kubectl apply -f green.yml -n ${NAMESPACE}

# Wait for the new deployment to roll out successfully
echo "Waiting for deployment ${DEPLOYMENT_NAME} to roll out..."
kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=${TIMEOUT}s

# Get the service's External IP
EXTERNAL_IP=$(kubectl get service ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$EXTERNAL_IP" ]; then
  echo "Error: No external IP found for the service ${SERVICE_NAME}"
  exit 1
fi

echo "External IP for ${SERVICE_NAME} is ${EXTERNAL_IP}"

# Wait for the service to be reachable
echo "Waiting for the service ${SERVICE_NAME} to be reachable at ${EXTERNAL_IP}..."
for ((i=1; i<=${TIMEOUT}; i++)); do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${EXTERNAL_IP})
  if [ $HTTP_STATUS -eq 200 ]; then
    echo "Service ${SERVICE_NAME} is reachable at ${EXTERNAL_IP}"
    exit 0
  fi
  sleep 1
done

echo "Timed out waiting for the service ${SERVICE_NAME} to be reachable"
exit 1