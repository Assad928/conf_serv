#Installez Fast HTTP Server [Nginx] et configurez HTTP / Proxy Server avec lui.
apt -y install nginx
#Configure Nginx
vi /etc/nginx/sites-available/default
# linge 46: changer de nom d'hôte
server_name www.srv.world;
systemctl restart nginx
#Il s'agit du paramètre d'hébergement virtuel pour Nginx.
#Par exemple, configurez un nom de domaine supplémentaire [virtual.host].
#Configure Nginx
vi /etc/nginx/sites-available/virtual.host.conf
# creer un nouveau 
server {
    listen       80;
    server_name  www.virtual.host;

    location / {
        root   /var/www/virtual.host;
        index  index.html index.htm;
    }
}

mkdir /var/www/virtual.host
/etc/nginx/sites-enabled
/etc/nginx/sites-enabled# ln -s /etc/nginx/sites-available/virtual.host.conf ./
/etc/nginx/sites-enabled# systemctl restart nginx
#Créez une page de test pour vous assurer qu'elle fonctionne normalement.
 vi /var/www/virtual.host/index.html
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Nginx Virtual Host Test Page
</div>
</body>
</html>
#Activez Userdir pour que les utilisateurs ordinaires ouvrent leur site dans les répertoires personnels.

#Configure Nginx.
vi /etc/nginx/sites-available/default
# ajouter dans la section [serveur]
        location ~ ^/~(.+?)(/.*)?$ {
            alias /home/$1/public_html$2;
            index  index.html index.htm;
            autoindex on;
        }
systemctl restart nginx
#Create a test page with a common user to make sure it works normally.
chmod 711 /home/debian
mkdir ~/public_html
chmod 755 ~/public_html
vi ~/public_html/index.html
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Nginx UserDir Test Page
</div>
</body>
</html>
#Activez le paramètre SSL / TLS pour utiliser la connexion SSL.
Configure Nginx.
vi /etc/nginx/sites-available/default
# ajouter a la fin 
# remplacez le chemin des certificats par le vôtre
server {
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;

        ssl_prefer_server_ciphers  on;
        ssl_ciphers  'ECDH !aNULL !eNULL !SSLv2 !SSLv3';
        ssl_certificate  /etc/letsencrypt/live/www.srv.world/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/www.srv.world/privkey.pem;

        root /var/www/html;
        server_name www.srv.world;
        location / {
                try_files $uri $uri/ =404;
        }
}
systemctl restart nginx
#Si vous souhaitez configurer la connexion HTTP pour rediriger vers HTTPS (toujours sur SSL / TLS), configurez comme suit.
vi /etc/nginx/sites-available/default
# ajouter dans la section d'écoute 80 port
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        return 301 https://$host$request_uri;
    }
systemctl restart nginx
#Configurez l'environnement exécutable CGI sur Nginx.
#Installez FastCGI Wrap et configurez Nginx pour cela.
apt -y install fcgiwrap
cp /usr/share/doc/fcgiwrap/examples/nginx.conf /etc/nginx/fcgiwrap.conf
vi /etc/nginx/fcgiwrap.conf
location /cgi-bin/ {
  # Disable gzip (it makes scripts feel slower since they have to complete
  # before getting gzipped)
  gzip off;

  # Set the root to /usr/lib (inside this location this means that we are
  # giving access to the files under /usr/lib/cgi-bin)
  # change
  root  /var/www;

  # Fastcgi socket
  fastcgi_pass  unix:/var/run/fcgiwrap.socket;

  # Fastcgi parameters, include the standard ones
  include /etc/nginx/fastcgi_params;

  # Adjust non standard parameters (SCRIPT_FILENAME)
  # change
  fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;
}

mkdir /var/www/cgi-bin
chmod 755 /var/www/cgi-bin
root@www:~# vi /etc/nginx/sites-available/default
# add into the [server] section
server {
        .....
        .....
        include fcgiwrap.conf;
}

systemctl restart nginx
#Créez un script de test sous le répertoire dans lequel vous définissez l'exécutable CGI (dans cet exemple, c'est [var / www / cgi-bin]) et accédez-y pour vérifier que CGI fonctionne normalement.
 vi /var/www/cgi-bin/index.py
#!/usr/bin/env python

print "Content-type: text/html\n\n"
print "<html>\n<body>"
print "<div style=\"width: 100%; font-size: 40px; font-weight: bold; text-align: center;\">"
print "Python Script Test Page"
print "</div>\n</body>\n</html>"
chmod 705 /var/www/cgi-bin/index.py
#Configurez Nginx en tant que serveur proxy inverse.
#Par exemple, configurez Nginx de la même manière que les accès HTTP à [www.srv.world] sont transmis à [dlp.srv.world].
vi /etc/nginx/sites-available/default
# changee comme suit [server] section
    server {
        listen      80 default_server;
        listen      [::]:80 default_server;
        server_name www.srv.world;

        proxy_redirect           off;
        proxy_set_header         X-Real-IP $remote_addr;
        proxy_set_header         X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header         Host $http_host;

        location / {
            proxy_pass http://dlp.srv.world/;
        }
    }
systemctl restart nginx
#Définissez log_format sur le serveur principal Nginx pour enregistrer l'en-tête X-Forwarded-For.
 vi /etc/nginx/nginx.conf
# ajouter  [http] section
http {
        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
}
vi /etc/nginx/sites-available/default
# ajouter  [server] section
# spécifiez votre réseau local pour [set_real_ip_from]
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        set_real_ip_from   10.0.0.0/24;
        real_ip_header     X-Forwarded-For;
}
systemctl restart nginx
#Configurez Nginx en tant que serveur d'équilibrage de charge.
#Cet exemple est basé sur l'environnement comme suit.
 vi /etc/nginx/nginx.conf
#ajouter dans[http] section
# [backup] signifie que ce serveur est équilibré uniquement lorsque les autres serveurs sont en panne
# [weight=*]
signifie équilibrer le poids
http {
        upstream backends {
                server node01.srv.world:80 weight=2;
                server node02.srv.world:80;
                server node03.srv.world:80 backup;
        }
}
vi /etc/nginx/sites-available/default
#changer comme suit dans  [server] section
server {
        listen      80 default_server;
        listen      [::]:80 default_server;
        server_name www.srv.world;

        proxy_redirect          off;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        Host $http_host;

        location / {
                proxy_pass http://backends;
        }
}
systemctl restart nginx

