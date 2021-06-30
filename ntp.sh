#Installez NTPd et configurez le serveur NTP pour l'ajustement de l'heure. NTP utilise 123 / UDP.
apt -y install ntp
vi /etc/ntp.conf
# ligne 23: commenter
# pool 0.debian.pool.ntp.org iburst
# pool 1.debian.pool.ntp.org iburst
# pool 2.debian.pool.ntp.org iburst
# pool 3.debian.pool.ntp.org iburst
# ajouter des serveurs dans votre fuseau horaire pour synchroniser les heures
server ntp.nict.jp iburst
server ntp1.jst.mfeed.ad.jp iburst
# line 52: ajoutez la plage réseau que vous autorisez à recevoir des demandes
restrict 10.0.0.0 mask 255.255.255.0 nomodify notrap
systemctl restart ntp
# voir  status
ntpq -p
#Configurez le client NTP.
#Les paramètres du client NTP sont pour la plupart les mêmes que 
#ceux du serveur, donc reportez-vous aux paramètres NTPd ou 
#aux paramètres Chrony. Pour des paramètres différents de celui 
#du serveur, les clients n'ont pas besoin de recevoir de demandes 
#de synchronisation d'horloge d'autres ordinateurs, il n'est donc 
#pas nécessaire de définir une autorisation d'accès.
#Si vous n'utilisez pas le démon de service NTP mais utilisez une commande 
#pour synchroniser l'heure à la fois, exécutez comme suit.
apt -y install chrony
chronyc makestep







