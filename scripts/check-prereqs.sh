#!/usr/bin/env bash
# Vérifie que l'environnement (WSL2 Ubuntu) peut faire tourner le lab.
set -u

ok()   { printf '  \033[32m[OK]\033[0m   %s\n' "$1"; }
warn() { printf '  \033[33m[WARN]\033[0m %s\n' "$1"; }
ko()   { printf '  \033[31m[KO]\033[0m   %s\n' "$1"; FAILED=1; }
FAILED=0

echo "Vérification des prérequis :"

if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
  ok "docker $(docker version --format '{{.Server.Version}}')"
  if docker info --format '{{.OperatingSystem}}' | grep -qi 'docker desktop'; then
    warn "Docker Desktop détecté : containerlab recommande Docker Engine natif dans WSL2"
  fi
else
  ko "docker absent ou daemon inaccessible"
fi

if command -v containerlab >/dev/null; then
  ok "containerlab $(containerlab version 2>/dev/null | awk '/version:/ {print $2; exit}')"
else
  ko "containerlab absent (bash -c \"\$(curl -sL https://get.containerlab.dev)\" -- -v 0.59.0)"
fi

for bin in make python3; do
  if command -v "$bin" >/dev/null; then ok "$bin"; else ko "$bin absent (sudo apt install -y make python3-venv)"; fi
done

# Le noyau doit gérer le filtrage VLAN du bridge et les sous-interfaces 802.1Q
if [ -r /proc/config.gz ]; then
  for opt in CONFIG_BRIDGE_VLAN_FILTERING CONFIG_VLAN_8021Q; do
    if zcat /proc/config.gz | grep -q "^${opt}=[ym]"; then ok "noyau : $opt"; else ko "noyau : $opt manquant"; fi
  done
else
  warn "/proc/config.gz illisible : support VLAN du noyau non vérifié"
fi

exit "$FAILED"
