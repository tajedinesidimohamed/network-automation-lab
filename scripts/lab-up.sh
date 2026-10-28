#!/usr/bin/env bash
# Démarre le lab : construit les images si besoin puis déploie la topologie.
set -euo pipefail
cd "$(dirname "$0")/.."

FRR_IMAGE="netlab/frr:9.1.0-r1"
ALPINE_IMAGE="netlab/alpine-net:3.20.3-r2"

build_if_missing() {
  local image=$1 context=$2
  if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo ">> Construction de l'image $image"
    docker build -t "$image" "$context"
  fi
}

./scripts/check-prereqs.sh
build_if_missing "$FRR_IMAGE" images/frr
build_if_missing "$ALPINE_IMAGE" images/alpine-net

echo ">> Déploiement de la topologie"
sudo containerlab deploy -t topology.clab.yml --reconfigure
