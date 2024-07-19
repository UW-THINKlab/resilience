#!/bin/bash

set -e

secretName="regcred"

secretCount=$(kubectl get secret $secretName --no-headers --ignore-not-found | wc -l)

if [ $secretCount -gt 0 ]; then
    echo "Secret $secretName already exists"
    exit 0
fi

echo "Creating secret $secretName"
kubectl \
    create \
    secret \
    docker-registry \
    $secretName \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=$DOCKER_USERNAME \
    --docker-password=$DOCKER_PASSWORD
