#!/usr/bin/env bash
# Arrête le lab et supprime les conteneurs, liens et fichiers générés.
set -euo pipefail
cd "$(dirname "$0")/.."

sudo containerlab destroy -t topology.clab.yml --cleanup
