FRR_IMAGE    := netlab/frr:9.1.0-r1
ALPINE_IMAGE := netlab/alpine-net:3.20.3-r2

# Environnement Python du projet (Ansible, pytest)
VENV ?= .venv
BIN  := $(abspath $(VENV))/bin
# Variable explicite : Ansible ignore un ansible.cfg situé dans un dossier
# accessible en écriture à tous (cas de /mnt/c, /mnt/d sous WSL).
ANSIBLE := ANSIBLE_CONFIG=$(CURDIR)/ansible/ansible.cfg $(BIN)/ansible-playbook

.PHONY: help check setup build deploy inspect configure destroy

help: ## Affiche cette aide
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

check: ## Vérifie les prérequis (docker, containerlab, noyau)
	@./scripts/check-prereqs.sh

setup: ## Crée le venv Python et installe Ansible + collections
	python3 -m venv $(VENV)
	$(BIN)/pip install -q -r requirements.txt
	$(BIN)/ansible-galaxy collection install -r ansible/requirements.yml -p ansible/collections

build: ## (Re)construit les images Docker du lab
	docker build -t $(FRR_IMAGE) images/frr
	docker build -t $(ALPINE_IMAGE) images/alpine-net

deploy: ## Démarre le lab
	@./scripts/lab-up.sh

inspect: ## Liste les nœuds du lab
	sudo containerlab inspect -t topology.clab.yml

configure: ## Configure tout le lab avec Ansible
	$(ANSIBLE) ansible/site.yml

destroy: ## Arrête et supprime le lab
	@./scripts/lab-down.sh
