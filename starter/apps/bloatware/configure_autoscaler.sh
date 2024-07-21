#!/bin/bash

# The script stops if any command fails
set -e

AWS_ACCOUNT="607531995438"
CLUSTER_NAME="udacity-cluster"
REGION="us-east-2"

# Create a node autoscaling configuration by setting up an IAM Open ID connect provider
echo "Associating IAM OIDC provider with EKS cluster..."
eksctl utils associate-iam-oidc-provider \
  --cluster $CLUSTER_NAME \
  --approve \
  --region $REGION

# Change the AWS Account number before the executing the command below.
eksctl create iamserviceaccount \
--name cluster-autoscaler \
--namespace kube-system \
--cluster udacity-cluster \
--attach-policy-arn "arn:aws:iam::607531995438:policy/udacity-k8s-autoscale" \
--approve --region $REGION

# Apply the cluster autoscaler configuration
echo "Applying cluster autoscaler configuration..."
kubectl apply -f cluster-autoscale.yml