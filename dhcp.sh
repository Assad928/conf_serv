#Configurer le serveur DHCP
#Configurez le serveur DHCP (Dynamic Host Configuration Protocol). Le serveur DHCP utilise 67 / UDP
apt -y install isc-dhcp-server
vi /etc/default/isc-dhcp-server
# ligne 4: decommenter 
DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
# ligne 17,18: spécifiez l'interface à écouter (remplacez le nom IF par votre environnement)
# sinon utilisez IPv6, commentez la ligne
INTERFACESv4="ens2"
INTERFACESv6="ens2"
 vi /etc/dhcp/dhcpd.conf
# ligne 7: specifie le nom de domaine 
option domain-name "srv.world";
# ligne 8: spécifier le nom d'hôte ou l'adresse IP du serveur de noms
option domain-name-servers dlp.srv.world;
# ligne 21: decommenter 
authoritative;
# ajouer a la fin 
# spécifier l'adresse réseau et le masque de sous-réseau
subnet 10.0.0.0 netmask 255.255.255.0 {
    # specify default gateway
    option routers      10.0.0.1;
    # specify subnet-mask
    option subnet-mask  255.255.255.0;
    # specify the range of leased IP address
    range dynamic-bootp 10.0.0.200 10.0.0.254;
} 
systemctl restart isc-dhcp-server
#Configurer le client DHCP
#Sur le client Debian, configurez comme suit pour obtenir l'adresse IP du serveur DHCP.
#Le nom de l'interface [ens2] est différent sur chaque environnement, remplacez-le par le vôtre.
# line 12: change
iface ens3 inet dhcp
systemctl restart ifup@ens2