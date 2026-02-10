#!/usr/bin/env bash
set -euo pipefail

DOCKER_REPOSITORY="brunomassaini"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

build_and_push() {
  local name="$1"
  local dockerfile="$2"
  local context="$3"
  local image="${DOCKER_REPOSITORY}/${name}:${IMAGE_TAG}"

  docker build --platform "$DOCKER_PLATFORM" -t "$image" -f "$dockerfile" "$context"
  docker push "$image"
}

build_and_push "openstatus-workflows" "apps/workflows/Dockerfile" "."
build_and_push "openstatus-server" "apps/server/Dockerfile" "."
build_and_push "openstatus-dashboard" "apps/dashboard/Dockerfile" "."
build_and_push "openstatus-status-page" "apps/status-page/Dockerfile" "."
build_and_push "openstatus-private-location" "apps/private-location/Dockerfile" "apps/private-location"
build_and_push "openstatus-private-probe" "apps/checker/private-location.Dockerfile" "apps/checker"

kubectl apply -f k8s/

kubectl rollout status deployment/openstatus-workflows
kubectl rollout status deployment/openstatus-server
kubectl rollout status deployment/openstatus-dashboard
kubectl rollout status deployment/openstatus-status-page
kubectl rollout status deployment/openstatus-private-location
kubectl rollout status deployment/openstatus-private-probe

kubectl rollout restart deployment/openstatus-workflows
kubectl rollout restart deployment/openstatus-server
kubectl rollout restart deployment/openstatus-dashboard
kubectl rollout restart deployment/openstatus-status-page
kubectl rollout restart deployment/openstatus-private-location
kubectl rollout restart deployment/openstatus-private-probe
