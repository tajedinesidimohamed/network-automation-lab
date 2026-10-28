# Image routeur : FRRouting + outils du lab.
#  - dnsmasq  : utilisé en mode relais DHCP sur r-core (FRR n'a pas de relais)
#  - python3  : requis par frr-reload.py et par la connexion Ansible docker
#  - tcpdump  : captures .pcap (phase 5)
FROM quay.io/frrouting/frr:9.1.0

RUN apk add --no-cache dnsmasq python3 tcpdump iproute2

# Fichiers de démarrage des démons (quels démons lancer), pas de la config
# de routage : celle-ci (frr.conf) est générée par Ansible.
COPY daemons vtysh.conf /etc/frr/
RUN chown frr:frr /etc/frr/daemons /etc/frr/vtysh.conf \
 && : > /etc/frr/frr.conf && chown frr:frr /etc/frr/frr.conf
