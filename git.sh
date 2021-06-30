#Installez et configurez Git qui est le système de contrôle de révision
#Install Git.
dnf -y install git
#Il est possible d'utiliser pour n'importe quel utilisateur commun.
#Par exemple, créez un référentiel avec un utilisateur sur localhost.
# create an empty repository
mkdir project.git
cd project.git
git init --bare
cd
# créer un répertoire de travail
mkdir work
cd work
git init
# définir le nom d'utilisateur et l'adresse e-mail
git config --global user.name "assad"
git config --global user.email "m@gmail.com"
# create a test file and apply it to repository
echo testfile > testfile1.txt
git add testfile1.txt
git commit testfile1.txt -m "Initial Commit"
git push /home/cent/project.git master
git ls-files
# attribuez un nom à repository
git remote add origin /home/cent/project.git
git remote -v
git remote show origin
#possible de pousser avec le nom que vous avez défini ci-dessus
echo testfile > testfile2.txt
git add testfile2.txt
git commit testfile2.txt -m "New Commit testfile2.txt"
git push origin master
# pour le cas de cloner le référentiel existant dans un répertoire de travail vide
mkdir ~/work2
cd ~/work2
git clone /home/cent/project.git
#Il est possible d'accéder aux référentiels Git via SSH.
#Par exemple, accédez à un repository Git [dlp: srv.world/home/cent/project.git] depuis un hôte distant via SSH. Comme dans le cas de cet exemple, il doit accéder avec un utilisateur qui a le même UID avec un utilisateur du propriétaire du référentiel.
mkdir work
cd work
# clone repository via SSH
git clone ssh://cent@dlp.srv.world/home/cent/project.git
cd project
ls
git config --global user.name "Server World"
git config --global user.email "cent@node01.srv.world"
echo test >> testfile1.txt
git commit testfile1.txt -m "Update testfile1.txt"
git remote -v
git push origin master
#Par exemple, accédez à un référentiel Git [dlp: srv.world/home/cent/project.git] depuis un 
#hôte distant via SSH. Comme dans le cas de cet exemple, il doit accéder avec 
#un utilisateur qui a le même UID avec un utilisateur du propriétaire du référentiel.Créez 
#des repository partagés que certains utilisateurs peuvent utiliser.

#créer un groupe à partager et définir des utilisateurs dans le groupe.
groupadd project01
# add users to the group
usermod -G project01 cent
usermod -G project01 redhat
#Créez un repository partagé avec un utilisateur.
# create a directory for repository and change group
mkdir project.git
chgrp project01 project.git
cd project.git
chmod 755 /home/cent
# set empty share repository
git init --bare --shared
ll -d /home/cent/project.git
#Vérifiez d'utiliser le référentiel avec les utilisateurs qui sont dans le groupe 
#pour le partage ajouté dans
mkdir work
cd work
git init
git config --global user.name "Server World"
git config --global user.email "redhat@dlp.srv.world"
# create a test file and push it to repository
echo testfile > testfile1.txt
git add testfile1.txt
git commit testfile1.txt -m "Initial Commit"
git remote add origin ssh://redhat@dlp.srv.world/home/cent/project.git
git push origin master


