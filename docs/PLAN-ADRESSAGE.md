# Plan d'adressage

Source de vérité pour la phase 1. À partir de la phase 2, ces valeurs sont
décrites en YAML dans `ansible/` et les configurations en sont générées.

## Sous-réseaux

| Segment | VLAN | Réseau | Adresses |
|---|---|---|---|
| RH | 10 | 10.10.10.0/24 | passerelle r-core `.1`, pool DHCP `.100–.199` |
| DEV | 20 | 10.10.20.0/24 | passerelle r-core `.1`, pool DHCP `.100–.199` |
| SERVEURS | 30 | 10.10.30.0/24 | passerelle r-core `.1`, srv-infra `.10` (statique) |
| Transit r-core ↔ r-edge | – | 10.0.0.0/30 | r-core `.1`, r-edge `.2` |
| Transit r-edge ↔ isp | – | 203.0.113.0/30 | isp `.1`, r-edge `.2` |
| Loopbacks (router-id) | – | 10.255.0.0/24 | r-core `.1`, r-edge `.2`, isp `.3` |
| « Internet » fictif | – | 8.8.8.0/24 | loopback isp `8.8.8.8/32` |
| Management containerlab | – | 10.99.0.0/24 | voir tableau des nœuds |

## Nœuds et interfaces

| Nœud | Rôle | Interface | Adresse / VLAN | Mgmt |
|---|---|---|---|---|
| isp | Routeur FAI, AS 65002 | eth1 | 203.0.113.1/30 | 10.99.0.11 |
| | | lo | 10.255.0.3/32, 8.8.8.8/32 | |
| r-edge | Routeur de bordure, AS 65001 | eth1 | 203.0.113.2/30 | 10.99.0.12 |
| | | eth2 | 10.0.0.2/30 | |
| | | lo | 10.255.0.2/32 | |
| r-core | Routeur cœur, router-on-a-stick | eth1 | 10.0.0.1/30 | 10.99.0.13 |
| | | eth2.10 | 10.10.10.1/24 | |
| | | eth2.20 | 10.10.20.1/24 | |
| | | eth2.30 | 10.10.30.1/24 | |
| | | lo | 10.255.0.1/32 | |
| sw | Switch (bridge `br0`) | eth1 | trunk VLAN 10, 20, 30 | 10.99.0.20 |
| | | eth2 | accès VLAN 10 | |
| | | eth3 | accès VLAN 20 | |
| | | eth4 | accès VLAN 30 | |
| pc-rh | Poste RH | eth1 | DHCP → 10.10.10.10 (réservé), MAC 02:00:00:00:10:10 | 10.99.0.31 |
| pc-dev | Poste DEV | eth1 | DHCP → 10.10.20.10 (réservé), MAC 02:00:00:00:20:20 | 10.99.0.32 |
| srv-infra | DHCP + DNS (dnsmasq) | eth1 | 10.10.30.10/24, MAC 02:00:00:00:30:10 | 10.99.0.40 |

Les réservations DHCP `.10` (hors pool) donnent aux PC une adresse stable,
donc des enregistrements DNS stables.

## DNS interne (zone `lab.local`)

| Nom | Adresse |
|---|---|
| rh.lab.local | 10.10.10.10 |
| dev.lab.local | 10.10.20.10 |
| srv.lab.local | 10.10.30.10 |

## Remarque sur le réseau de management

Containerlab relie l'`eth0` de chaque conteneur au réseau de management et y
place une route par défaut. Elle sera supprimée par Ansible (phase 2) pour que
le trafic du lab passe uniquement par les liens simulés. Ansible et les tests
utilisent `docker exec`, qui ne dépend pas de cette route.
