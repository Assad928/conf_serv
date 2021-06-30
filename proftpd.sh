#Installez ProFTPD pour configurer le serveur FTP pour transférer les fichiers.
apt -y install proftpd
 vi /etc/proftpd/proftpd.conf
# ligne 11: désactiver si pas besoin d'IPv6
UseIPv6 off
# ligne 15: changer de nom d'hôte
ServerName "www.srv.world"
# ligne 36: décommenter (spécifier le répertoire racine pour chroot)
DefaultRoot ~
vi /etc/ftpusers
# ajouter des utilisateurs vous interdisez la connexion FTP
test
systemctl restart proftpd
#Configurez l'ordinateur client pour qu'il se connecte au serveur FTP. L'exemple ci-dessous concerne Debian.
apt -y install lftp
#La connexion avec le compte root est interdite par défaut, donc l'accès avec un utilisateur commun au serveur FTP.
# lftp [option] [hostname]
lftp -u debian www.srv.world
# afficher le répertoire actuel sur le serveur FTP
pwd
# afficher le repertoire actuel sur le serveur local
!pwd

#afficher les fichiers du repertoire actuel sur le serveur ftp
ls
#afficher les fichiers du repertoire sur le serveur local
!ls -l
#change de repetoire 
cd public_html
# uploader un fichier sur le serveur FTP
# "-a" signifie mode ascii (la valeur par défaut est le mode binaire)
put -a debian.txt test.txt
# uploader des fichiers sur le serveur FTP
mput -a test.txt test2.txt
# télécharger un fichier depuis un serveur FTP
get -a test.py
# telecharger des fichiers depuis un serveur FTP
mget -a test.txt test2.txt
#creer un repertoire sur le serveur FTP
mkdir testdir
#suprimer un repertoire sur le serveur FTP
rmdir testdir
#suprimer un fichier sur le serveur FTP
rm test2.txt
# suprimer des fichier sur le serveur FTP
mrm debian.txt test.txt
# exécuter des commandes avec! [commande]
!cat /etc/passwd
#pour quitter 
quit
#Configure ProFTPD to use SSL/TLS.
#Créez des certificats auto-signés. 
#mais si vous utilisez des certificats valides comme ceux de 
#Let's Encrypt ou d'autres, vous n'avez pas besoin de créer celui-ci.
cd /etc/ssl/private
openssl req -x509 -nodes -newkey rsa:2048 -keyout proftpd.pem -out proftpd.pem -days 365
chmod 600 proftpd.pem
#Configure ProFTPD.
 vi /etc/proftpd/proftpd.conf
#ligne 140: decommenter 
Include /etc/proftpd/tls.conf
vi /etc/proftpd/tls.conf
# ligne 10-12: decommenter
TLSEngine               on
TLSLog                  /var/log/proftpd/tls.log
TLSProtocol             TLSv1.2

# ligne 27-28: decommenter et changr 
TLSRSACertificateFile          /etc/ssl/private/proftpd.pem
TLSRSACertificateKeyFile       /etc/ssl/private/proftpd.pem
systemctl restart proftpd
#Configurez le client FTP pour utiliser la connexion FTPS.
 vi ~/.lftprc
# creer un nouveau
set ftp:ssl-auth TLS
set ftp:ssl-force true
set ftp:ssl-protect-list yes
set ftp:ssl-protect-data yes
set ftp:ssl-protect-fxp yes
set ssl:verify-certificate no



