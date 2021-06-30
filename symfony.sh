#Symfony est un framework PHP gratuit, open source et haute performance qui peut être utilisé 
#pour créer des applications Web, des API, des microservices et des services Web. 
#Symfony vous permet de créer des applications Web sans codage monotone et extensif. 
#Symfony est livré avec un ensemble d'outils qui vous aide à tester, 
#déboguer et documenter des projets. Symfony utilise le modèle de conception 
#Model-View-Controller et vise à accélérer la création et la maintenance des applications Web.
#pour installer symfony il faut d'abord installer apache2,mariadb et php
# et quelque dependance :
apt-get install apache2 mariadb-server php php-fpm php-common php-mysql php-gmp php-curl php-intl php-mbstring php-xmlrpc php-gd php-bcmath php-soap php-ldap php-imap php-xml php-cli php-zip git unzip wget -y
#ensuite installer le Composer sur votre serveur. 
#Vous pouvez télécharger le script d'installation de Composer avec la commande suivante:
wget https://getcomposer.org/installer
#apres on execute l'installateur
php installer
#ensuite on install symfony
#Exécutez ce programme d'installation pour créer un binaire appelé symfony
wget https://get.symfony.com/cli/installer -O - | bash
#ajoutez la ligne suivante à votre fichier de configuration shell:
export PATH="$HOME/.symfony/bin:$PATH"
#installez-le globalement sur votre système:
#pour on fait un deplacement
mv /root/.symfony/bin/symfony /usr/local/bin/symfony
#pour creer une application symfony
symfony new --full my_project
#pour ce qui veulent creer un microservice, une application console ou une API
symfony new my_project
#Les composants Symfony sont un ensemble de bibliothèques découplées et réutilisables qui peuvent être utilisées dans n'importe quelle application PHP.
#comme nous avons deja installer composer 
#exécutez cette commande pour ajouter un composant Symfony dans votre application:
composer require 
#pour demarrer un projet dans la racine du projet  
symfony server:start 
















