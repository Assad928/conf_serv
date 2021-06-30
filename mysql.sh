#Installez MySQL pour configurer le serveur de base de données
dnf module -y install mysql:8.0
firewall-cmd --add-service=mysql --permanent
firewall-cmd --reload
#Paramètres initiaux de MySQL
mysql_secure_installation
#Pour la sauvegarde et la restauration des données MySQL, il est possible d'exécuter avec [mysqldump].
#Exécutez [mysqldump] pour récupérer les données de vidage de MySQL.
# dump toutes les tables et vider toutes les données dans MySQL
# lors du dump des données, la lecture est également verrouillée, il est donc impossible d'utiliser les bases de données
mysqldump -u root -p --lock-all-tables --all-databases --events > mysql_dump.sql
# dump toutes les données sans verrouillage mais avec transaction
# a assuré l'intégrité des données par l'option [--single-transaction]
mysqldump -u root -p --single-transaction --all-databases --events > mysql_dump.sql
#dump d'une base de données spécifique
mysqldump -u root -p test_database --single-transaction --events > mysql_dump.sql
#Pour restaurer les données à partir d'une sauvegarde sur un autre hôte, exécutez comme suit.
#Avant la restauration, transférez les données de vidage vers l'hôte cible avec [rsync] ou [scp] et ainsi de suite.
#pour toutes les données dumpee, importez simplement un fichier
mysql -u root -p < mysql_dump.sql
#pour les données sauvegardées avec une base de données spécifique,
# créez d'abord une base de données vide avec le même nom de base de données et ensuite, importez un fichier
mysql -u root -p test_database < mysql_dump.sql





