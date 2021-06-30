#Installez Squid et configurez le serveur proxy.
apt -y install squid
#Il s'agit des paramètres de proxy de transfert courants.
vi /etc/squid/squid.conf
acl CONNECT method CONNECT
#ligne 1209: ajouter (définir ACL pour le réseau interne)
acl my_localnet src 10.0.0.0/24
# ligne 1397: decommenter
http_access deny to_localhost
# ligne 1408: commenter and ajoute la ligne (appliquer ACL pour le réseau interne)
#http_access allow localhost
http_access allow my_localnet
# ligne 5611: ajouter 
request_header_access Referer deny all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
# ligne 8264: ajouter
# forwarded_for on
forwarded_for off
systemctl restart squid
#Configurer Proxy Client pour se connecter au serveur Proxy
vi /etc/profile.d/proxy.sh
# create new (définir les paramètres de proxy sur les variables d'environnement)
MY_PROXY_URL="prox.srv.world:3128"

HTTP_PROXY=$MY_PROXY_URL
HTTPS_PROXY=$MY_PROXY_URL
FTP_PROXY=$MY_PROXY_URL
http_proxy=$MY_PROXY_URL
https_proxy=$MY_PROXY_URL
ftp_proxy=$MY_PROXY_URL

export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy
source /etc/profile.d/proxy.sh
vi /etc/apt/apt.conf
# creer nouveau
Acquire::http::proxy "http://prox.srv.world:3128/";
Acquire::https::proxy "https://prox.srv.world:3128/";
Acquire::ftp::proxy "ftp://prox.srv.world:3128/";
vi ~/.curlrc
# creer nouveau
proxy=prox.srv.world:3128
 vi /etc/wgetrc
# ajouter a la fin 
http_proxy = prox.srv.world:3128
https_proxy = prox.srv.world:3128
ftp_proxy = prox.srv.world:3128
#Configurez les paramètres de proxy comme suit sur le client Windows.
#Par exemple sur Firefox,
#Ouvrez [Modifier] - [Préférences] et accédez à [Général] - [Proxy réseau] et cliquez sur le bouton [Paramètres]
#Définissez l'authentification de base et limitez Squid pour que les utilisateurs exigent une authentification
apt -y install apache2-utils
#Configure Squid to set Basic Authentication.
vi /etc/squid/squid.conf
acl CONNECT method CONNECT
# ligne 1209: ajouter suit pour l'authentification de base
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/.htpasswd
auth_param basic children 5
auth_param basic realm Squid Basic Authentication
auth_param basic credentialsttl 5 hours
acl password proxy_auth REQUIRED
http_access allow password
systemctl restart squid
# ajouter un utilisateur: créer un nouveau fichier avec l'option [-c]
htpasswd -c /etc/squid/.htpasswd ubuntu
New password:     # set password
Re-type new password:
Adding password for user ubuntu
#Configurez le client proxy Ubuntu pour l'authentification de base.
vi /etc/profile.d/proxy.sh
#ajouter un nouveau
# username:password@proxyserver:port
MY_PROXY_URL="ubuntu:password@prox.srv.world:3128"

HTTP_PROXY=$MY_PROXY_URL
HTTPS_PROXY=$MY_PROXY_URL
FTP_PROXY=$MY_PROXY_URL
http_proxy=$MY_PROXY_URL
https_proxy=$MY_PROXY_URL
ftp_proxy=$MY_PROXY_URL

export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy
source /etc/profile.d/proxy.sh
# or it's possible to set proxy settings for each application, not System wide
# for apt
 vi /etc/apt/apt.conf
#creer un nouveau
Acquire::http::proxy "http://ubuntu:password@prox.srv.world:3128/";
Acquire::https::proxy "https://ubuntu:password@prox.srv.world:3128/";
Acquire::ftp::proxy "ftp://ubuntu:password@prox.srv.world:3128/";
vi ~/.curlrc
# creer un nouveau
proxy=prox.srv.world:3128
proxy-user=ubuntu:password
 vi /etc/wgetrc
# ajouter a la fin 
http_proxy = prox.srv.world:3128
https_proxy = prox.srv.world:3128
ftp_proxy = prox.srv.world:3128
proxy_user = ubuntu
proxy_passwd = password
#Pour les clients Windows, aucun des paramètres spécifiques, mais lors de l'accès à un site Web, le serveur proxy nécessite une authentification comme suit, puis saisissez le nom d'utilisateur et le mot de passe.
#Configurez Squid en tant que serveur proxy inverse.
#Configure Squid.
vi /etc/squid/squid.conf
# ligne 1409: ajouter (autoriser l'accès http à tous)
http_access allow all
# ligne 1907: changer comme suit (spécifier le serveur Web principal pour le site par défaut)
#http_port 3128
http_port 80 accel defaultsite=www.srv.world
https_port 443 accel defaultsite=www.srv.world tls-cert=/etc/letsencrypt/live/prox.srv.world/fullchain.pem tls-key=/etc/letsencrypt/live/prox.srv.world/privkey.pem
# ligne 3252: ajouter
cache_peer www.srv.world parent 80 0 no-query originserver
# ligne 3378: ajouter (taille du cache mémoire)
cache_mem 256 MB
# ligne 3650: ajouter
#nombre signifie ⇒ [taille du cache disque] [nombre de répertoires au niveau supérieur] [nombre de répertoires au 2ème niveau]
cache_dir ufs /var/spool/squid 256 16 256
systemctl restart squid
#Modifiez les paramètres du DNS ou du routeur si besoin, et faites-lui écouter les requêtes HTTP / HTTPS sur le serveur Squid. Ce n'est pas grave si le serveur http principal répond comme suit.
