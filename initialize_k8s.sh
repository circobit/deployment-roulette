#!/bin/bash

set -e

NAMESPACE="kube-system"
CONFIGMAP_NAME="aws-auth"

# Retrieve the current ConfigMap and save to a file
kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o yaml > current-configmap.yaml

# Check if the retrieval was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve the ConfigMap. Please check your cluster access."
  exit 1
fi

# Extract metadata from the current ConfigMap using jq
creationTimestamp=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o json | jq -r '.metadata.creationTimestamp')
uid=$(kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o json | jq -r '.metadata.uid')

# Create the new ConfigMap content
cat <<EOF > new-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: $CONFIGMAP_NAME
  namespace: $NAMESPACE
  creationTimestamp: "$creationTimestamp"
  uid: "$uid"
data:
  mapRoles: |
    - rolearn: arn:aws:iam::607531995438:role/app-udacity-eks-node-role
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::607531995438:role/udacity-github-actions
      username: system:admin
      groups:
        - system:masters
EOF

# Replace the old ConfigMap with the new one
kubectl replace -f new-configmap.yaml

# Check if the replacement was successful
if [ $? -eq 0 ]; then
  echo "ConfigMap replaced successfully."
else
  echo "Failed to replace the ConfigMap."
  exit 1
fi

# Cleanup configmap file
rm current-configmap.yaml new-configmap.yaml

# Apply Apps
kubectl apply -f starter/apps/hello-world
kubectl apply -f starter/apps/canary/index_v1_html.yml
kubectl apply -f starter/apps/canary/index_v2_html.yml
kubectl apply -f starter/apps/canary/canary-v1.yml
kubectl apply -f starter/apps/canary/canary-svc.yml
kubectl apply -f starter/apps/blue-green/blue.yml
kubectl apply -f starter/apps/blue-green/blue-svc.yml
kubectl apply -f starter/apps/blue-green/green-svc.yml
kubectl apply -f starter/apps/blue-green/index_blue_html.yml
kubectl apply -f starter/apps/blue-green/index_green_html.yml

