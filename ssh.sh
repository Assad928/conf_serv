#Configurez le serveur SSH pour gérer un serveur à partir de l'ordinateur remoré. SSH utilise 22 / TCP.
apt -y install openssh-server
vi /etc/ssh/sshd_config
#ligne 32: decommenter et changer a no
PermitRootLogin no
systemctl restart ssh 
#configurer le client ssh sur linux
apt -y install openssh-client
#Connectez-vous au serveur SSH avec un utilisateur commun.
ssh debian@dlp.srv.world
#sur windows on a putty et le cmd
#il est possibl de faire avec ssh 
#C'est l'exemple de l'utilisation de SCP (Secure Copy).
# copiez le [test.txt] sur le serveur local vers distant [www.srv.world]
scp ./test.txt debian@www.srv.world:~/
# copiez le [/home/debian/test.txt] sur le serveur distant [www.srv.world] sur le serveur local
scp debian@www.srv.world:/home/debian/test.txt ./test.txt
#C'est un exemple d'utiliser SFTP (SSH File Transfer Protocol). La fonction de serveur SFTP est activée par défaut, mais sinon, activez-la pour ajouter la ligne [Subsystem sftp / usr / lib / openssh / sftp-server] dans [/ etc / ssh / sshd_config].
# sftp [Option] [user@hostname]
sftp debian@www.srv.world
#apres la connection vous aurea
sftp>
#dan le prompt afficher le répertoire actuel sur le serveur distant
pwd
##dans le prompt afficher le répertoire actuel sur le serveur local
!pwd
#dans le prompt afficher les fichiers dans le répertoire actuel sur le serveur FTP
ls 
# sur le serveur local 
!ls
#change de repertoire
cd
#télécharger un fichier sur un serveur distant
#put : envoie un fichier vers le serveur ;
#get : télécharge un fichier depuis le serveur.
#get -r pour télécharge un repertoire
put test.txt 
# créer un répertoire sur un serveur distant
mkdir testdir
# supprimer un répertoire sur un serveur distant
rmdir testdir
# supprimer un fichier sur un serveur distant
rm test2.txt
# pour quitter 
quit
#Configurez le serveur SSH pour vous connecter avec l'authentification par paire de clés. Créez une clé privée pour le client et une clé publique pour le serveur pour le faire.
#creer une paire de clef RSA
ssh-keygen
#deplacer les clefs 
mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
#Transférez la clé secrète créée sur le serveur vers un client, puis il est possible de se connecter avec l'authentification par paire de clés.
mkdir ~/.ssh
chmod 700 ~/.ssh
# copiez la clé secrète dans le répertoire ssh local
scp debian@10.0.0.30:/home/debian/.ssh/id_rsa ~/.ssh/


