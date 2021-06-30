#Configurez le serveur LDAP afin de partager les comptes des utilisateurs dans vos réseaux locaux
 apt -y install slapd ldap-utils
 #confirm settings
slapcat
dn: dc=srv,dc=world
objectClass: top
objectClass: dcObject
objectClass: organization
o: srv.world
dc: srv
structuralObjectClass: organization
entryUUID: 08b3ae24-42fa-1039-8da0-ef6bf22a19f7
creatorsName: cn=admin,dc=srv,dc=world
createTimestamp: 20190725073200Z
entryCSN: 20190725073200.275709Z#000000#000#000000
modifiersName: cn=admin,dc=srv,dc=world
modifyTimestamp: 20190725073200Z

dn: cn=admin,dc=srv,dc=world
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9RG5yMWY1VGFnemc1WUlPMDJOQzY3dC9zbHVYZXhTZFo=
structuralObjectClass: organizationalRole
entryUUID: 08b9c85e-42fa-1039-8da1-ef6bf22a19f7
creatorsName: cn=admin,dc=srv,dc=world
createTimestamp: 20190725073200Z
entryCSN: 20190725073200.315769Z#000000#000#000000
modifiersName: cn=admin,dc=srv,dc=world
modifyTimestamp: 20190725073200Z
#Ajoutez un dn de base pour les utilisateurs et les groupes.
vi base.ldif
# creer un nouveau
# modifier votre propre suffixe pour le champ [dc = srv, dc = world]
dn: ou=people,dc=srv,dc=world
objectClass: organizationalUnit
ou: people
dn: ou=groups,dc=srv,dc=world
objectClass: organizationalUnit
ou: groups 
#tapez la commande
ldapadd -x -D cn=admin,dc=srv,dc=world -W -f base.ldif
Enter LDAP Password:     # LDAP admin password (set in installation of openldap)
adding new entry "ou=people,dc=srv,dc=world"
adding new entry "ou=groups,dc=srv,dc=world"
#Ajoutez des comptes d'utilisateurs LDAP dans le serveur OpenLDAP.
#ajouter un utilisateur .
# generer un mot de passe crypter 
slappasswd
New password:
Re-enter new password:
vi ldapuser.ldif
#creer un nouveau
# remplacez par votre propre nom de domaine pour la section "dc = ***, dc = ***"
dn: uid=buster,ou=people,dc=srv,dc=world
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: buster
sn: ubuntu
userPassword: {SSHA}xxxxxxxxxxxxxxxxx
loginShell: /bin/bash
uidNumber: 2000
gidNumber: 2000
homeDirectory: /home/buster

dn: cn=buster,ou=groups,dc=srv,dc=world
objectClass: posixGroup
cn: buster
gidNumber: 2000
memberUid: buster
#tapez la commade
ldapadd -x -D cn=admin,dc=srv,dc=world -W -f ldapuser.ldif
Enter LDAP Password:
adding new entry "uid=buster,ou=people,dc=srv,dc=world"
adding new entry "cn=buster,ou=groups,dc=srv,dc=world"

#Ajoutez des utilisateurs et des groupes dans passwd / group local à l'annuaire LDAP.
vi ldapuser.sh
# extraire les utilisateurs locaux et les groupes qui ont un UID de 1 000 à 9 999 chiffres
# remplacez "SUFFIX = ***" par votre propre nom de domaine
# ceci est un exemple, libre de modifier
#!/bin/bash

SUFFIX='dc=srv,dc=world'
LDIF='ldapuser.ldif'

echo -n > $LDIF
GROUP_IDS=()
grep "x:[1-9][0-9][0-9][0-9]:" /etc/passwd | (while read TARGET_USER
do
    USER_ID="$(echo "$TARGET_USER" | cut -d':' -f1)"

    USER_NAME="$(echo "$TARGET_USER" | cut -d':' -f5 | cut -d',' -f1 )"
    [ ! "$USER_NAME" ] && USER_NAME="$USER_ID"

    LDAP_SN="$(echo "$USER_NAME" | awk '{print $2}')"
    [ ! "$LDAP_SN" ] && LDAP_SN="$USER_ID"

    LASTCHANGE_FLAG="$(grep "${USER_ID}:" /etc/shadow | cut -d':' -f3)"
    [ ! "$LASTCHANGE_FLAG" ] && LASTCHANGE_FLAG="0"

    SHADOW_FLAG="$(grep "${USER_ID}:" /etc/shadow | cut -d':' -f9)"
    [ ! "$SHADOW_FLAG" ] && SHADOW_FLAG="0"

    GROUP_ID="$(echo "$TARGET_USER" | cut -d':' -f4)"
    [ ! "$(echo "${GROUP_IDS[@]}" | grep "$GROUP_ID")" ] && GROUP_IDS=("${GROUP_IDS[@]}" "$GROUP_ID")

    echo "dn: uid=$USER_ID,ou=people,$SUFFIX" >> $LDIF
    echo "objectClass: inetOrgPerson" >> $LDIF
    echo "objectClass: posixAccount" >> $LDIF
    echo "objectClass: shadowAccount" >> $LDIF
    echo "sn: $LDAP_SN" >> $LDIF
    echo "givenName: $(echo "$USER_NAME" | awk '{print $1}')" >> $LDIF
    echo "cn: $(echo "$USER_NAME" | awk '{print $1}')" >> $LDIF
    echo "displayName: $USER_NAME" >> $LDIF
    echo "uidNumber: $(echo "$TARGET_USER" | cut -d':' -f3)" >> $LDIF
    echo "gidNumber: $(echo "$TARGET_USER" | cut -d':' -f4)" >> $LDIF
    echo "userPassword: {crypt}$(grep "${USER_ID}:" /etc/shadow | cut -d':' -f2)" >> $LDIF
    echo "gecos: $USER_NAME" >> $LDIF
    echo "loginShell: $(echo "$TARGET_USER" | cut -d':' -f7)" >> $LDIF
    echo "homeDirectory: $(echo "$TARGET_USER" | cut -d':' -f6)" >> $LDIF
    echo "shadowExpire: $(passwd -S "$USER_ID" | awk '{print $7}')" >> $LDIF
    echo "shadowFlag: $SHADOW_FLAG" >> $LDIF
    echo "shadowWarning: $(passwd -S "$USER_ID" | awk '{print $6}')" >> $LDIF
    echo "shadowMin: $(passwd -S "$USER_ID" | awk '{print $4}')" >> $LDIF
    echo "shadowMax: $(passwd -S "$USER_ID" | awk '{print $5}')" >> $LDIF
    echo "shadowLastChange: $LASTCHANGE_FLAG" >> $LDIF
    echo >> $LDIF
done

for TARGET_GROUP_ID in "${GROUP_IDS[@]}"
do
    LDAP_CN="$(grep ":${TARGET_GROUP_ID}:" /etc/group | cut -d':' -f1)"

    echo "dn: cn=$LDAP_CN,ou=groups,$SUFFIX" >> $LDIF
    echo "objectClass: posixGroup" >> $LDIF
    echo "cn: $LDAP_CN" >> $LDIF
    echo "gidNumber: $TARGET_GROUP_ID" >> $LDIF

    for MEMBER_UID in $(grep ":${TARGET_GROUP_ID}:" /etc/passwd | cut -d':' -f1,3)
    do
        UID_NUM=$(echo "$MEMBER_UID" | cut -d':' -f2)
        [ $UID_NUM -ge 1000 -a $UID_NUM -le 9999 ] && echo "memberUid: $(echo "$MEMBER_UID" | cut -d':' -f1)" >> $LDIF
    done
    echo >> $LDIF
done
)
#executer le programme 
bash ldapuser.sh
ldapadd -x -D cn=admin,dc=srv,dc=world -W -f ldapuser.ldif
Enter LDAP Password:
adding new entry "uid=debian,ou=people,dc=srv,dc=world"

adding new entry "uid=ubuntu,ou=people,dc=srv,dc=world"

adding new entry "uid=redhat,ou=people,dc=srv,dc=world"

adding new entry "cn=debian,ou=groups,dc=srv,dc=world"

adding new entry "cn=ubuntu,ou=groups,dc=srv,dc=world"

adding new entry "cn=redhat,ou=groups,dc=srv,dc=world"
#Si vous souhaitez supprimer l'utilisateur ou le groupe LDAP, procédez comme suit.
ldapdelete -x -W -D 'cn=admin,dc=srv,dc=world' "uid=buster,ou=people,dc=srv,dc=world"
ldapdelete -x -W -D 'cn=admin,dc=srv,dc=world' "cn=buster,ou=groups,dc=srv,dc=world"
#Configurez le client LDAP afin de partager les comptes des utilisateurs dans vos réseaux locaux.
apt -y install libnss-ldap libpam-ldap ldap-utils
vi /etc/nsswitch.conf
#ligne 7: ajouter 
passwd:         compat systemd ldap
group:          compat systemd ldap
shadow:         compat
vi /etc/pam.d/common-password
#ligne 26: changer ( remove [use_authtok] )
password        [success=1 user_unknown=ignore default=die]     pam_ldap.so try_first_pass

vi /etc/pam.d/common-session
# ajouter à la fin si besoin (créer le répertoire personnel automatiquement lors de la connexion initiale)
session optional        pam_mkhomedir.so skel=/etc/skel umask=077
reboot
# changr le mot de passe 
passwd

#Configurez LDAP sur SSL / TLS pour que la connexion soit sécurisée.
#On this exmaple, create and use self-signed certificates like here.
cp /etc/ssl/private/server.key \
/etc/ssl/private/server.crt \
/etc/ssl/certs/ca-certificates.crt \
/etc/ldap/sasl2/
chown openldap. /etc/ldap/sasl2/server.key \
/etc/ldap/sasl2/server.crt \
/etc/ldap/sasl2/ca-certificates.crt
vi mod_ssl.ldif
# creer un nouveau 
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/sasl2/ca-certificates.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/sasl2/server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/sasl2/server.key
ldapmodify -Y EXTERNAL -H ldapi:/// -f mod_ssl.ldif
#Configurer le client LDAP
#Si vous souhaitez vous assurer que la connexion entre le serveur LDAP et le client est cryptée, utilisez tcpdump ou un autre logiciel de capture réseau sur le serveur LDAP.
echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf
vi /etc/pam_ldap.conf
# ligne 258: decommenter 
ssl start_tls
vi /etc/libnss-ldap.conf
# ligne 291: decommenter 
ssl start_tls
reboot
#Configurez la réplication d'OpenLDAP pour continuer le service d'annuaire si le serveur maître d'OpenLDAP était en panne.
#Le serveur maître OpenLDAP est appelé [Provider] et le serveur OpenLDAP Slave est appelé [Consumer] sur OpenLDAP.
#Configurez le fournisseur LDAP. Ajoutez le module syncprov.
vi mod_syncprov.ldif
# creer un nouveau
dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulePath: /usr/lib/ldap
olcModuleLoad: syncprov.la

ldapadd -Y EXTERNAL -H ldapi:/// -f mod_syncprov.ldif
vi syncprov.ldif
# creer nouveau
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpSessionLog: 100
ldapadd -Y EXTERNAL -H ldapi:/// -f syncprov.ldif
#Configure LDAP Consumer.
vi syncrepl.ldif
# creer in nouveau 
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncRepl
olcSyncRepl: rid=001
  # LDAP server's URI
  provider=ldap://10.0.0.30:389/
  bindmethod=simple
  # propre suffixe de domaine
  binddn="cn=admin,dc=srv,dc=world"
  # directory manager's password
  credentials=password
  searchbase="dc=srv,dc=world"
  # includes subtree
  scope=sub
  schemachecking=on
  type=refreshAndPersist
  # [retry interval] [retry times] [interval of re-retry] [re-retry times]
  retry="30 5 300 3"
  # replication interval
  interval=00:00:05:00

dapadd -Y EXTERNAL -H ldapi:/// -f syncrepl.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"

#confirmer les paramètres pour rechercher des données
ldapsearch -x -b 'ou=people,dc=srv,dc=world'
dn: ou=people,dc=srv,dc=world
objectClass: organizationalUnit
ou: people

# buster, people, srv.world
dn: uid=buster,ou=people,dc=srv,dc=world
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: buster
sn: ubuntu
loginShell: /bin/bash
uidNumber: 2000
gidNumber: 2000
homeDirectory: /home/buster
uid: buster
.....
.....
#Configurez également le client LDAP pour lier le consommateur LDAP.
vi /etc/pam_ldap.conf
# ligne 27: add LDAP Consumer
uri ldap://dlp.srv.world/ ldap://node01.srv.world/
vi /etc/libnss-ldap.conf
# ligne 27: add LDAP Consumer
uri ldap://dlp.srv.world/ ldap://node01.srv.world/
#Configurez la réplication multi-maître OpenLDAP.
#Pour les paramètres du fournisseur / consommateur, 
#il est impossible d'ajouter des données sur le serveur consommateur, 
#mais si vous configurez ces paramètres multi-maîtres, 
#il est possible d'ajouter sur n'importe quel serveur maître
#Configurez comme suit sur tous les serveurs. Ajoutez le module syncprov.
 vi mod_syncprov.ldif
# creer nouveau 
dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulePath: /usr/lib/ldap
olcModuleLoad: syncprov.la

ldapadd -Y EXTERNAL -H ldapi:/// -f mod_syncprov.ldif

vi syncprov.ldif
# creer nouveau 
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpSessionLog: 100
ldapadd -Y EXTERNAL -H ldapi:/// -f syncprov.ldif
#Configurez comme suit sur tous les serveurs.
#Mais seuls les paramètres [olcServerID] et [provider = ***] définissent une valeur différente sur chaque serveur.
vi master01.ldif
# creer un nouveau
dn: cn=config
changetype: modify
replace: olcServerID
# spécifier le numéro d'identifiant uniq sur chaque serveur
olcServerID: 101

dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncRepl
olcSyncRepl: rid=001
  # specify another LDAP server's URI
  provider=ldap://10.0.0.51:389/
  bindmethod=simple
  # own domain name
  binddn="cn=admin,dc=srv,dc=world"
  # directory manager's password
  credentials=password
  searchbase="dc=srv,dc=world"
  # includes subtree
  scope=sub
  schemachecking=on
  type=refreshAndPersist
  # [retry interval] [retry times] [interval of re-retry] [re-retry times]
  retry="30 5 300 3"
  # replication interval
  interval=00:00:05:00
-
add: olcMirrorMode
olcMirrorMode: TRUE

dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
ldapmodify -Y EXTERNAL -H ldapi:/// -f master01.ldif
#Configurer le client LDAP pour lier tous les serveurs LDAP
vi /etc/pam_ldap.conf
# ligne 27: add LDAP Master
uri ldap://dlp.srv.world/ ldap://node01.srv.world/
vi /etc/libnss-ldap.conf
# ligne 27: add LDAP Master
uri ldap://dlp.srv.world/ ldap://node01.srv.world/



