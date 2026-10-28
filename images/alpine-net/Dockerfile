# Image légère pour le switch, les PC et le serveur d'infrastructure.
#  - iproute2  : ip / bridge (VLAN filtering)
#  - dnsmasq   : DHCP + DNS sur srv-infra
#  - bind-tools: dig / nslookup pour les tests DNS
#  - tcpdump   : captures .pcap
#  - python3   : requis par la connexion Ansible docker
#  - tini      : init minimal en PID 1, récupère les processus terminés
#                (sinon les démons arrêtés restent à l'état zombie)
# udhcpc (client DHCP) est fourni par busybox.
FROM alpine:3.20.3

RUN apk add --no-cache iproute2 dnsmasq bind-tools tcpdump python3 tini \
 && bridge -V

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sleep", "infinity"]
