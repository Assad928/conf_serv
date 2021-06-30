#Installez Postfix pour configurer le serveur SMTP. SMTP utilise 25 / TCP.
#Cet exemple montre comment configurer SMTP-Auth pour utiliser la fonction SASL de Dovecot.
cp /usr/share/postfix/main.cf.dist /etc/postfix/main.cf
vi /etc/postfix/main.cf
# ligne 78: decommenter
mail_owner = postfix
# ligne 94: decommenter et specifie le nom d'hote
myhostname = mail.srv.world
# ligne 102: decommenter et specifie le nom de domaine
mydomain = srv.world
# ligne 123: decommenter
myorigin = $mydomain
# ligne 137: decommenter
inet_interfaces = all
# ligne 185: decommenter
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
# ligne 228: decommenter
local_recipient_maps = unix:passwd.byname $alias_maps
# ligne 270: decommenter
mynetworks_style = subnet
# ligne 287: ajouter l'adresse local du reseaux
mynetworks = 127.0.0.0/8, 10.0.0.0/24
# ligne 407: decommenter
alias_maps = hash:/etc/aliases
# ligne 418: decommenter
alias_database = hash:/etc/aliases
# ligne 440: decommenter
home_mailbox = Maildir/
# ligne 576: commenter et ajouter
#smtpd_banner = $myhostname ESMTP $mail_name (Debian)
smtpd_banner = $myhostname ESMTP
# ligne 650: ajouter
sendmail_path = /usr/sbin/postfix
# ligne 655: ajouter
newaliases_path = /usr/bin/newaliases
# ligne 660: ajouter
mailq_path = /usr/bin/mailq
# ligne 666: ajouter
setgid_group = postdrop
# ligne 670: commenter
#html_directory =
# ligne 674: commenter
#manpage_directory =
# ligne 679: commenter
#sample_directory =
# ligne 683: commenter
#readme_directory =
# ajouter à la fin: limiter la taille d'un e-mail à 10M
message_size_limit = 10485760
# limiter la taille de la boîte aux lettres à 1G
mailbox_size_limit = 1073741824
# SMTP-Auth settings
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $myhostname
smtpd_recipient_restrictions = permit_mynetworks, permit_auth_destination, permit_sasl_authenticated, reject
newaliases
systemctl restart postfix
#Installez Dovecot pour configurer le serveur POP / IMAP. POP utilise 110 / TCP, IMAP utilise 143 / TCP.
#Cet exemple montre comment configurer pour fournir la fonction SASL à Postfix.
apt -y install dovecot-core dovecot-pop3d dovecot-imapd
vi /etc/dovecot/dovecot.conf
# ligne 30: decommenter
listen = *, ::
vi /etc/dovecot/conf.d/10-auth.conf
# ligne 10: décommenter et modifier (autoriser l'authentification en texte brut)
disable_plaintext_auth = no
# ligne 100: ajouter
auth_mechanisms = plain login
vi /etc/dovecot/conf.d/10-mail.conf
# ligne 30: changer pour Maildir
mail_location = maildir:~/Maildir
vi /etc/dovecot/conf.d/10-master.conf
# ligne 107-109: commenter et ajouter 
  # Postfix smtp-auth
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
systemctl restart dovecot
#Ajoutez des comptes d'utilisateurs de messagerie pour utiliser le service de messagerie.
#Cet exemple concerne le cas où vous utilisez des comptes d'utilisateurs du système d'exploitation.
# install mail client
apt -y install mailutils
# définir des variables d'environnement pour utiliser Maildir
echo 'export MAIL=$HOME/Maildir/' >> /etc/profile.d/mail.sh
# ajouter un utilsateur systeme [debian]
adduser debian
# m'envoyer un mail [mail (username)@(hostname)]
mail debian@localhost
# input Cc
Cc:
# input subject
Subject: Test Mail#1
# input messages
This is the first mail.

# pour terminer les messages, appuyez sur [Ctrl + D] key

# voir les e-mails reçus
mail

# entrez le numéro que vous souhaitez voir un e-mail
? 1

#pour quitter 
? q
#Configurez votre client de messagerie sur votre PC. Cet exemple montre avec Mozilla Thunderbird.
#Ajoutez des comptes d'utilisateurs de messagerie pour utiliser le service de messagerie.
#Cet exemple concerne le cas où vous utilisez des comptes d'utilisateurs de messagerie virtuels et non des comptes de système d'exploitation.
#Configurez des paramètres supplémentaires pour Postfix et Dovecot.
# créer un utilisateur administrateur pour les boîtes aux lettres virtuelles
adduser --uid 20000 --disabled-password --disabled-login vmail
vi /etc/postfix/main.cf
# ligne 185:commenter
#mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
# ajouter a la fin 
# si spécifiez plusieurs domaines, spécifiez une virgule ou un espace séparés
virtual_mailbox_domains = srv.world, virtual.host
virtual_mailbox_base = /home/vmail
virtual_mailbox_maps = hash:/etc/postfix/virtual-mailbox
virtual_uid_maps = static:20000
virtual_gid_maps = static:20000

vi /etc/dovecot/conf.d/10-auth.conf
# ligne 100: ajouter
auth_mechanisms = cram-md5 plain login
# ligne 122: commenter
#!include auth-system.conf.ext
# ligne 125: decommenter 
!include auth-passwdfile.conf.ext
# line 128: uncomment
!include auth-static.conf.ext
vi /etc/dovecot/conf.d/auth-passwdfile.conf.ext
# ligne 8: changer
passdb {
  driver = passwd-file
  args = scheme=CRAM-MD5 username_format=%u /etc/dovecot/users

# ligne 11: comment out [userdb] section all
#userdb {
#  driver = passwd-file
#  args = username_format=%u /etc/dovecot/users
#.....
#.....
#}
}
vi /etc/dovecot/conf.d/auth-static.conf.ext
# ligne 21-24: decommenter et  changer
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/home/vmail/%d/%n
}
vi /etc/dovecot/conf.d/10-mail.conf
# ligne 30: changer
mail_location = maildir:/home/vmail/%d/%n/Maildir
systemctl restart postfix dovecot
#Ajoutez des comptes d'utilisateurs de messagerie virtuels.
vi /etc/postfix/virtual-mailbox
# creer un nouveau
# [user account] [mailbox]
debian@srv.world   srv.world/debian/Maildir/
debian@virtual.host   virtual.host/debian/Maildir/
postmap /etc/postfix/virtual-mailbox
# générer un mot de passe crypté
doveadm pw -s CRAM-MD5
vi /etc/dovecot/users
# creer un nouveau
# [user account] [password]
debian@srv.world:{CRAM-MD5}xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
debian@virtual.host:{CRAM-MD5}xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#Configurez SSL / TLS pour crypter les connexions.
#SMTP-Submission utilise 587 / TCP (STARTTLS utilisé), SMTPS utilise 465 / TCP, POP3S utilise 995 / TCP, IMAPS utilise 993 / TCP.
#Configure Postfix and Dovecot.
vi /etc/postfix/main.cf
# ajouter a la fin
smtpd_use_tls = yes
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
smtpd_tls_cert_file = /etc/letsencrypt/live/mail.srv.world/fullchain.pem
smtpd_tls_key_file = /etc/letsencrypt/live/mail.srv.world/privkey.pem
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
vi /etc/postfix/master.cf
# ligne 17-21: décommenter comme suit
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
#  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes

# line 29-31:décommenter comme suit
smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
vi /etc/dovecot/conf.d/10-ssl.conf
# ligne 6: changer
ssl = yes
# ligne 12,13: décommenter et spécifier les certificats
ssl_cert = </etc/letsencrypt/live/mail.srv.world/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.srv.world/privkey.pem
systemctl restart postfix dovecot
#Pour les paramètres du client, (Mozilla Thunderbird)
#Ouvrez la propriété du compte et accédez à [Paramètres du serveur] 
#dans le volet gauche, puis sélectionnez [STARTTLS] ou [SSL / TLS] 
#dans le champ [Sécurité de la connexion] dans le volet droit. 
#(cet exemple montre comment sélectionner [STARTTLS])

#Configurez pour Virtulal Domain pour envoyer un e-mail 
#avec un autre nom de domaine différent du domaine d'origine.
#Cet exemple concerne le cas où vous utilisez des comptes d'utilisateurs du système d'exploitation.
#Si vous utilisez des comptes de boîte aux lettres virtuelle, reportez-vous ici.
#voir la congig du virtual user 





