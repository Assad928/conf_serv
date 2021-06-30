#Installez Apache2 pour configurer le serveur HTTP. HTTP utilise 80 / TCP
apt -y install apache2
#Configure Apache2.
vi /etc/apache2/conf-enabled/security.conf
# ligne 25: changer
ServerTokens Prod
vi /etc/apache2/mods-enabled/dir.conf
# ligne 2: ajouter un nom de fichier auquel il ne peut accéder qu'avec le nom du répertoire
DirectoryIndex index.html index.htm
vi /etc/apache2/apache2.conf
# ligne 70: ajouter le nom du serveur 
ServerName www.srv.world
vi /etc/apache2/sites-enabled/000-default.conf
# ligne 11: modifier l'adresse e-mail de l'administrateur
ServerAdmin webmaster@srv.world
systemctl restart apache2
#Configurez Apache2 pour utiliser des scripts PHP.
apt -y install php php-cgi libapache2-mod-php php-common php-pear php-mbstring
#Configure Apache2.
a2enconf php7.3-cgi
vi /etc/php/7.3/apache2/php.ini
#ligne 960: décommentez et ajoutez votre fuseau horaire
date.timezone = "Asia/Tokyo"
systemctl restart apache2
#Créez une page de test PHP et accédez-y à partir du PC client avec un navigateur Web. C'est OK si la page suivante est affichée.
vi /var/www/html/index.php
#Activez CGI et utilisez des scripts Python sur Apache2.
apt -y install python
#Activez le module CGI.
a2enmod cgid
systemctl restart apache2
#Après avoir activé CGI, les scripts CGI sont autorisés à s'exécuter 
#dans le répertoire [/ usr / lib / cgi-bin] par défaut. 
#Par conséquent, par exemple, si un script Python [index.cgi] est placé sous le répertoire, 
#il est possible d'accéder à l'URL [http: // (serveur Apache2) /cgi-bin/index.cgi] depuis les clients.
# creer un script tete 
cat > /usr/lib/cgi-bin/test_script <<'EOF'
#!/usr/bin/env python
print "Content-type: text/html\n\n"
print "Hello CGI\n"
EOF
chmod 705 /usr/lib/cgi-bin/test_script
# essayez d'accéder
curl http://localhost/cgi-bin/test_script
#Si vous souhaitez autoriser CGI dans d'autres répertoires sauf par défaut, configurez comme suit.
#Par exemple, autorisez dans [/ var / www / html / cgi-enabled].
vi /etc/apache2/conf-available/cgi-enabled.conf
# creer un nouveau
# traite [.cgi] et [.py] en tant que scripts CGI
<Directory "/var/www/html/cgi-enabled">
    Options +ExecCGI
    AddHandler cgi-script .cgi .py
</Directory>

mkdir /var/www/html/cgi-enabled
a2enconf cgi-enabled
systemctl restart apache2
#Créez une page de test CGI et accédez-y à partir du PC client avec un 
#navigateur Web. C'est OK si la page suivante est affichée.
vi /var/www/html/cgi-enabled/index.py
#!/usr/bin/env python

print "Content-type: text/html\n\n"
print "<html>\n<body>"
print "<div style=\"width: 100%; font-size: 40px; font-weight: bold; text-align: center;\">"
print "Python Script Test Page"
print "</div>\n</body>\n</html>"
chmod 705 /var/www/html/cgi-enabled/index.py

#Activez userdir, les utilisateurs peuvent créer des sites Web avec ce paramètre.
#Configure Apache2.
a2enmod userdir
systemctl restart apache2
#Créez une page de test avec un utilisateur commun et accédez-y à partir d'un PC client avec un navigateur Web. 
#C'est OK si la page suivante est affichée.
mkdir ~/public_html
vi ~/public_html/index.html
#Configurez les hébergements virtuels pour utiliser plusieurs noms de domaine
#L'exemple ci-dessous est défini sur l'environnement dont le nom de domaine est [srv.world], le nom de domaine virtuel est
#[virtual.host (répertoire racine [/ home / ubuntu / public_html])].
#Il est également nécessaire de définir les paramètres Userdir pour cet exemple.
#Configure Apache2.
vi /etc/apache2/sites-available/virtual.host.conf
# create new for [virtual.host]
<VirtualHost *:80>
    ServerName www.virtual.host
    ServerAdmin webmaster@virtual.host
    DocumentRoot /home/debian/public_html
    ErrorLog /var/log/apache2/virtual.host.error.log
    CustomLog /var/log/apache2/virtual.host.access.log combined
    LogLevel warn
</VirtualHost>
a2ensite virtual.host
systemctl restart apache2
#Créez une page de test et accédez-y à partir d'un ordinateur client 
#avec un navigateur Web. C'est OK si la page suivante est affichée.
mkdir ~/public_html
vi ~/public_html/index.html
#Configurez le paramètre SSL / TLS pour utiliser une connexion HTTPS chiffrée sécurisée.
Configure Apache2.
 vi /etc/apache2/sites-available/default-ssl.conf
# ligne 3: modifier l'adresse e-mail de l'administrateur
ServerAdmin webmaster@srv.world
# ligne 32,33: modification des certificats obtenus dans la section [1]
SSLCertificateFile      /etc/letsencrypt/live/www.srv.world/cert.pem
SSLCertificateKeyFile   /etc/letsencrypt/live/www.srv.world/privkey.pem

# ligne 42: décommenter et modifier le fichier chaîne obtenu dans la section [1]
SSLCertificateChainFile /etc/letsencrypt/live/www.srv.world/chain.pem
a2ensite default-ssl
a2enmod ssl
systemctl restart apache2
#Si vous souhaitez configurer la connexion HTTP pour rediriger vers HTTPS (toujours sur SSL / TLS), 
#configurez chaque hôte virtuel comme suit. Il est également possible de le définir dans [.htaccess] et non dans httpd.conf.
vi /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
a2enmod rewrite
systemctl restart apache2









