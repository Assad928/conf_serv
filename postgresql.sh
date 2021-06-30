#Installez PostgreSQL pour configurer le serveur de base de données.
apt -y install postgresql
vi /etc/postgresql/11/main/postgresql.conf
#ligne 59: décommentez et modifiez si vous autorisez les accès depuis des hôtes distants
listen_addresses = '*'
systemctl restart postgresql
#Définissez le mot de passe de l'utilisateur administrateur PostgreSQL, ajoutez un utilisateur et ajoutez également une base de données de test.
# definir un mot de passe 
su - postgres
psql -c "alter user postgres with password 'password'"
ALTER ROLE
# ajouter DB user [debian] 
createuser debian
# créer une base de données de test (le propriétaire est l'utilisateur ci-dessus)
createdb testdb -O debian
#Connectez-vous en tant qu'utilisateur juste ajouté ci-dessus et utilisez DataBase comme opération de test.
#voir les bases des donnees
psql -l
# connecter a la DB
psql testdb
# definir un mot de passe 
testdb=# alter user debian with password 'password'; 
ALTER ROLE
#creer la table  test
testdb=# create table test ( no int,name text ); 
CREATE TABLE

# inserer des donnees 
testdb=# insert into test (no,name) values (1,'debian'); 
INSERT 0 1

#afficher les donnees de la tables 
testdb=# select * from test; 
 no |  name
----+--------
  1 | debian
#supprimer la table test 
testdb=# drop table test; 
DROP TABLE
#pour quitter 
testdb=# \q 
# suprimer la base des donnees 
dropdb testdb



