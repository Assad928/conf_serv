#Anaconda est la plate-forme de science des données et d'apprentissage automatique Python / R 
#la plus populaire. Il est utilisé pour le traitement de données à grande échelle, 
#l'analyse prédictive et le calcul scientifique.
#La distribution Anaconda est livrée avec plus de 1 500 packages de données open source. 
#Il comprend également l'outil de ligne de commande conda et une interface utilisateur 
#graphique de bureau appelée Anaconda Navigator.
#pour l'installer il faut utiliser mirror web
#pour ca on va utiliser soite wget ou curl pour telecharger le script en ligne de commande 
#nous allons utiliser wget dans le repertoire /temp
wget -P /tmp https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
#executer le script pour l'nstaller 
sh /tmp/Anaconda3-2019.10-Linux-x86_64.sh
#Appuyez sur ENTRÉE pour continuer, puis sur ESPACE pour faire défiler la licence. 
#Une fois la vérification de la licence terminée, vous serez invité à accepter les 
#termes de la licence:

yes #pour tapez oui pour accepter 
#ensuite tapez:
ENTRÉE
#L'installation peut prendre un certain temps.
#apres 
yes
#Pour activer l'installation d'Anaconda, chargez la nouvelle variable d'environnement PATH 
#qui a été ajoutée par le programme d'installation d'Anaconda dans la session 
#shell actuelle avec la commande suivante:
source ~/.bashrc
#pour verifier l'installation 
conda info
#apres l'installation il faut faire une mis a jour 
conda update
conda update anaconda
#pour voir les packages
conda list 
#ou
pip list
#maintemant qu'on a installer anaconda 
#on va creer un environement virtual "geek_minato" avec python3
conda create --name geek_minato Python=3
#pour activate l'environement 
conda activate geek_minato
#pour sortir de l'environement 
conda deactivate
#pour sortir d'anaconda
conda deactivate
#pour installer un package par example numpy
conda install numpy
#ou
pip install numpy
#pour supprimer 
conda env remove -n geek_minato
















