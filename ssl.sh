#Créez les certificats SSL auto-signés de votre serveur. 
#Si vous utilisez votre serveur en tant qu'entreprise, 
#il vaut mieux acheter et utiliser des certificats formels.
cd /etc/ssl/private
openssl genrsa -aes128 -out server.key 2048
# supprimer la phrase de passe de la clé privée
openssl rsa -in server.key -out server.key
openssl req -new -days 3650 -key server.key -out server.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:JP   # country
State or Province Name (full name) [Some-State]:Hiroshima   # state
Locality Name (eg, city) []:Hiroshima  # city
Organization Name (eg, company) [Internet Widgits Pty Ltd]:GTS   # company
Organizational Unit Name (eg, section) []:Server World   # department
Common Name (e.g. server FQDN or YOUR name) []:dlp.srv.world   # server's FQDN
Email Address []:root@srv.world   # admin email

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

root@dlp:/etc/ssl/private# openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650
Signature ok
subject=C = JP, ST = Hiroshima, L = Hiroshima, O = GTS, OU = Server World, CN = dlp.srv.world, emailAddress = root@srv.world
Getting Private key
#Obtenez des certificats SSL de Let's Encrypt qui fournit des certificats SSL gratuits.
#Reportez-vous aux détails du site officiel de Let's Encrypt ci-dessous.
#https://letsencrypt.org/
#À propos, la date d'expiration d'un certificat est de 90 jours, vous devez donc mettre à jour dans les 90 prochains jours plus tard.
#Installez Certbot Client qui est l'outil pour obtenir des certificats de Let's Encrypt
apt -y install certbot
#Obtenez des certificats.
#Il faut qu'un serveur Web comme Apache httpd ou Nginx soit en cours d'exécution sur le serveur sur lequel vous travaillez.
#Si aucun serveur Web n'est en cours d'exécution, ignorez cette section et reportez-vous à la section [3].
#De plus, il faut qu'il soit possible d'accéder à partir d'Internet à votre serveur de travail sur le port 80 grâce à la vérification de Let's Encrypt.
#section serveur web

# for the option [--webroot], use a directory under the webroot on your server as a working temp
# -w [document root] -d [FQDN you'd like to get certs]
# FQDN (Fully Qualified Domain Name) : Hostname.Domainname
# if you'd like to get certs for more than 2 FQDNs, specify all like below
# ex : if get [srv.world] and [www.srv.world]
# ⇒ -d srv.world -d dlp.srv.world
root@dlp:~# certbot certonly --webroot -w /var/www/html -d srv.world

# for only initial using, register your email address and agree to terms of use
# specify valid email address
Enter email address (used for urgent notices and lost key recovery)

root@mail.srv.world 

<  OK  >           <Cancel>

# agree to the terms of use
Please read the Terms of Service at
     https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf.
     You must agree in order to register with the ACME server at       
     https://acme-v01.api.letsencrypt.org/directory                    

<Agree >           <Cancel>

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/srv.world/fullchain.pem. Your cert will
   expire on 2019-10-23. To obtain a new version of the certificate in
   the future, simply run Let's Encrypt again.
 - If you like Let's Encrypt, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

# success if [Congratulations] is shown
# certs are created under the [/etc/letsencrypt/live/(FQDN)/] directory

# cert.pem       ⇒ SSL Server cert(includes public-key)
# chain.pem      ⇒ intermediate certificate
# fullchain.pem  ⇒ combined file cert.pem and chain.pem
# privkey.pem    ⇒ private-key file
'
#Si aucun serveur Web n'est en cours d'exécution sur votre serveur de travail, 
#il est possible d'obtenir des certificats en utilisant la fonction 
#Serveur Web de Certbot. Quoi qu'il en soit, il faut qu'il soit 
#possible d'accéder depuis Internet à votre serveur de travail 
#sur le port 80 grâce à la vérification de Let's Encrypt.
#section3
# for the option [--standalone], use Certbot's Web Server feature
# -d [FQDN you'd like to get certs]
# FQDN (Fully Qualified Domain Name) : Hostname.Domainname
# if you'd like to get certs for more than 2 FQDNs, specify all like below
# ex : if get [srv.world] and [www.srv.world] ⇒ specify [-d srv.world -d www.srv.world]
root@dlp:~# certbot certonly --standalone -d dlp.srv.world

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/dlp.srv.world/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/dlp.srv.world/privkey.pem
   Your cert will expire on 2019-10-23. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
'
#Pour mettre à jour les certificats existants, procédez comme suit.
# update all certs which has less than 30 days expiration
# if you'd like to update certs which has more than 30 days expiration, add [--force-renew] option
certbot renew


