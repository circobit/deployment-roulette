#!/bin/bash

DEPLOY_INCREMENTS=1

function canary_deploy {
  NUM_OF_V1_PODS=$(kubectl get pods -n udacity | grep -c canary-v1)
  echo "Canary v1 PODS: $NUM_OF_V1_PODS"
  NUM_OF_V2_PODS=$(kubectl get pods -n udacity | grep -c canary-v2)
  echo "Canary v2 PODS: $NUM_OF_V2_PODS"

  kubectl scale deployment canary-v2 --replicas=$((NUM_OF_V2_PODS + $DEPLOY_INCREMENTS)) -n udacity
  kubectl scale deployment canary-v1 --replicas=$((NUM_OF_V1_PODS - $DEPLOY_INCREMENTS)) -n udacity
  
  # Check deployment rollout status every 1 second until complete.
  ATTEMPTS=0
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/canary-v2 -n udacity"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    ATTEMPTS=$((attempts + 1))
    sleep 1
  done
  echo "Canary deployment of $DEPLOY_INCREMENTS replicas successful!"
}

# Initialize canary-v2 deployment
kubectl apply -f starter/apps/canary/canary-v2.yml

sleep 1
# Begin canary deployment
while [ $(kubectl get pods -n udacity | grep -c canary-v1) -gt 2 ]
do
  canary_deploy
done

echo "Canary deployment of v2 successful"