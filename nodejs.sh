#Node.js est un environnement d'exécution JavaScript multiplateforme basé sur le JavaScript de 
#Chrome conçu pour exécuter du code JavaScript côté serveur. Avec Node.js, 
#vous pouvez créer des applications réseau évolutives.

#npm est le gestionnaire de packages par défaut pour Node.js qui aide 
#les développeurs à partager et réutiliser leur code.


#Pour installer Node.js et npm:
apt install nodejs npm
#pour voir la version installer
nodejs --version

#Au moment de la rédaction de cet article, la version dans les référentiels sur le serveur x
#est la v10.x qui est la dernière version LTS. Mais il ya des nouvelle version par exemple la version 
#14 lts qui est la plus recente en moment 
#comme on a la version 10.x sur notre serveur nous voulons mettre a jour notre node, pour ca nous allons
#utiliser nvm
#NVM (Node Version Manager) est un script bash qui vous permet de gérer plusieurs 
#versions de Node.js. Avec NVM, vous pouvez installer et 
#désinstaller toute version de Node.js que vous souhaitez utiliser ou tester.

#pour installer nvm:
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
#pour activer le nvm 
source ~/.profile
#pour installer la derniere version de node sans tague 
nvm install node
#mais si on veut installer la version stable, on cherche d'abord la version stable sur le site
#officiel de nojs la version lts, la version stable du moment est  v14.15.5
#pour l'installer:
nvm install 14.15.5
#pour lister les version installee 
nvm ls
#Pour changer le Node.js par défaut, par exemple en v14.15.5, utilisez:
nvm alias default 14.15.5
#pour desinstaller node et npm
apt remove nodejs npm
#pour executer un programme 
node 1.js
#pour debuguer un programme node js 
node --inspect 1.js
#pour la gestion de dependence 
npm init 
#pour le paquet en production 
npm install --save nom_module
#pour les paquets optionnelle
npm install --save-optional nom_module
#pour le dev
npm install --save-dev nom_module
#pour la mise a jour du paquet 
npm update
#la mise a jour d'un paquet 
npm update nom_module
#pour la suppression 
npm uninstall --save nom_module
npm uninstall --save-optional nom_module
npm uninstall --save-dev nom_module
#pour lister les modules
npm ls
#importer un module http
const http = require('http')

#installer des modules avec npm
npm install module 
#pour la recherche des paquets
sur le site npmjs.org
en ligne de commande
npm search nom_du paquet 





