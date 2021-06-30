#Configurez le serveur NFS pour partager des répertoires sur votre réseau.
#Cet exemple est basé sur l'environnement ci-dessous. voir figure nfs 
#Installez et configurez le serveur NFS. Dans cet exemple, configurez le répertoire [/ home] en tant que partage NFS.
apt -y install nfs-kernel-server
vi /etc/idmapd.conf
# ligne 6: décommenter et modifier votre nom de domaine
Domain = srv.world
vi /etc/exports
# paramètres d'écriture pour les exportations NFSts
/home 10.0.0.0/24(rw,no_root_squash)
systemctl restart nfs-server
#Configure NFS Client
#Configurez le client NFS. Dans cet exemple, montez le répertoire [/ home] à partir du serveur NFS.
apt -y install nfs-common
mount -t nfs dlp.srv.world:/home /home
df -hT
# /home du serveur NFS est monté
# si vous souhaitez monter avec NFSv3, ajoutez l'option '-o vers = 3'
mount -t nfs -o vers=3 dlp.srv.world:/home /home
#Configurez le montage NFS sur fstab pour le monter au démarrage du système.
 vi /etc/fstab
# add to the end like follows
dlp.srv.world:/home   /home  nfs     defaults        0       0
#Configurez le montage automatique si vous en avez besoin. Par exemple, définissez le répertoire NFS sur / mntdir.
apt -y install autofs
vi /etc/auto.master
# add to the end
/-    /etc/auto.mount
vi /etc/auto.mount
# create new : [mount point] [option] [location]
/mntdir -fstype=nfs,rw  dlp.srv.world:/home

mkdir /mntdir
systemctl restart autofs
# move to the mount point to verify it works normally
cd /mntdir
ll
cat /proc/mounts | grep mntdir



