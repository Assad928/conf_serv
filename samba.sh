#Installez Samba pour partager des dossiers ou des fichiers entre Windows et Linux.
#Par exemple, créez un répertoire de partage entièrement accessible auquel tout 
#le monde peut accéder et écrire sans authentification.
apt -y install samba
#Configure Samba
#creez le repertore de partage 
mkdir /home/share
chmod 777 /home/share
#le fichier de config
vi /etc/samba/smb.conf
# line 25: ajouter 
unix charset = UTF-8
# line 30: change (Windows' default)
workgroup = WORKGROUP
# line 37: décommentez et modifiez l'adresse IP que vous autorisez
interfaces = 127.0.0.0/8 10.0.0.0/24
# line 58: decommenter et ajouter 
bind interfaces only = yes
map to guest = Bad User
# ajouter a la fin 
# le repertoire de partage
[Share]
    # shared directory
    path = /home/share
    # writable
    writable = yes
    # guest OK
    guest ok = yes
    # guest only
    guest only = yes
    # fully accessed
    create mode = 0777
    # fully accessed
    directory mode = 0777
systemctl restart smbd
#Configurer sur le client Windows. Cet exemple est sur Windows 10.
#Sélectionnez [Ce PC] - [reseaux] comme dans l'exemple suivant.
#Spécifiez l'emplacement du dossier partagé dans la section Dossier comme l'exemple et cliquez sur le bouton [Terminer] pour entrer.
#Juste accédé au dossier partagé. Essayez de tester pour lire ou écrire certains fichiers ou dossiers.

#Par exemple, créez un répertoire de partage qui nécessite une authentification utilisateur.
#Configure Samba.
#creer un groud security
groupadd security
#creer le repertoire security
mkdir /home/security
#ajouter le groupe
chgrp security /home/security
chmod 770 /home/security
#le fichier de config
vi /etc/samba/smb.conf
# line 25: ajouter 
unix charset = UTF-8
# line 30: change (Windows' default)
workgroup = WORKGROUP
# line 37: uncomment and change IP address you allow
interfaces = 127.0.0.0/8 10.0.0.0/24
# line 44: uncomment
bind interfaces only = yes
# ajouter a la fin
# le repertoire a partager avec authentification
[Security]
    path = /home/security
    writable = yes
    create mode = 0770
    directory mode = 0770
    # guest not allowed
    guest ok = no
    # allow users only in [security] group
    valid users = @security

systemctl restart smbd
# ajouter un utilsateur dans la bse samba
smbpasswd -a debian
#ajouter l'utilisateu dans le groupe security
usermod -G security debian
#Configurer sur le client Windows. Cet exemple est sur Windows 10.
#Sélectionnez [Ce PC] - [reseaux] comme dans l'exemple suivant.
#Spécifiez l'emplacement du dossier partagé dans la section Dossier comme l'exemple et cliquez sur le bouton [Terminer] pour entrer.



#Configurez le contrôleur de domaine Samba Active Directory.
#Cet exemple se configure sur l'environnement ci-dessous.
#Nom de domaine: SMB01
#Royaume: SRV.WORLD
#Nom d'hôte: smb.srv.world
#Installer les packages requis
apt -y install samba krb5-config winbind smbclient
#Configure Samba AD DC.
# renommer ou supprimer la configuration par défaut
mv /etc/samba/smb.conf /etc/samba/smb.conf.org
samba-tool domain provision
# spécifier le royaume
Realm [SRV.WORLD]: 
# specify Domain name
 Domain [SRV]: SMB01 
# Entrez par défaut car il définit DC
 Server Role (dc, member, standalone) [dc]:
#Entrez par défaut car il utilise le DNS intégré
 DNS backend (SAMBA_INTERNAL, BIND9_FLATFILE, BIND9_DLZ, NONE) [SAMBA_INTERNAL]:
# si vous définissez le redirecteur DNS, spécifiez-le, sinon, indiquez [aucun]
 DNS forwarder IP address (write 'none' to disable forwarding) [10.0.0.10]: 10.0.0.10
# définir le mot de passe administrateur
# Ne définissez pas de mot de passe trivial, si vous le saisissez, l'assistant de configuration affiche une erreur
cp /var/lib/samba/private/krb5.conf /etc/
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl start samba-ad-dc
systemctl enable samba-ad-dc
# verify status
smbclient -L localhost -U%
#confirmez le niveau de domaine et ajoutez un utilisateur de domaine.
# confirm domain level
samba-tool domain level show
Domain and forest function level for domain 'DC=srv,DC=world'

Forest function level: (Windows) 2008 R2
Domain function level: (Windows) 2008 R2
Lowest function level of a DC: (Windows) 2008 R2

# add a domain user
samba-tool user create debian
New Password:   # set password
Retype Password:
User 'debian' created successfully
#Installez Samba pour partager des dossiers ou des fichiers entre Windows et Linux.
apt -y install samba
#Configure Samba.
groupadd security
mkdir /home/security
chgrp security /home/security
chmod 770 /home/security
vi /etc/samba/smb.conf
# ligne 25: ajouter 
unix charset = UTF-8
# ligne 30: changer (Windows' default)
workgroup = WORKGROUP
# line 37: décommentez et modifiez l'adresse IP que vous autorisez
interfaces = 127.0.0.0/8 10.0.0.0/24
# ligne 44: décommentez
bind interfaces only = yes
# add to the end
# any share name you like
[Security]
    path = /home/security
    writable = yes
    create mode = 0770
    directory mode = 0770
    # guest not allowed
    guest ok = no
    # allow users only in [security] group
    valid users = @security
systemctl restart smbd
# add user in Samba
smbpasswd -a debian
New SMB password:     # set password
Retype new SMB password:
Added user ubuntu.
usermod -G security debian
#Configurer sur le client Windows. Cet exemple est sur Windows 10.
#Sélectionnez [Ce PC] - [Map Network Drive] comme dans l'exemple suivant.
#Spécifiez l'emplacement du dossier partagé dans la section Dossier comme l'exemple et cliquez sur le bouton [Terminer] pour entrer.
#L'authentification est requise. Authentifiez-vous avec un utilisateur ajouté par la commande smbpasswd dans la section



