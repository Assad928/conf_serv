#Configurez RAID 1 pour ajouter 2 nouveaux disques sur un ordinateur.
#Cet exemple est basé sur l'environnement comme suit.
#Il montre d'installer de nouveaux disques [sdb] et [sdc] sur cet ordinateur et de configurer RAID 1
df -h
#Créez une partition sur de nouveaux disques et définissez l'indicateur RAID
parted --script /dev/sdb "mklabel gpt"
parted --script /dev/sdc "mklabel gpt"
parted --script /dev/sdb "mkpart primary 0% 100%"
parted --script /dev/sdc "mkpart primary 0% 100%"
parted --script /dev/sdb "set 1 raid on"
parted --script /dev/sdc "set 1 raid on"
#Configure RAID 1
dnf -y install mdadm
mdadm --create /dev/md0 --level=raid1 --raid-devices=2 /dev/sdb1 /dev/sdc1
# show status
cat /proc/mdstat
#Créez n'importe quel système de fichiers sur un périphérique RAID et montez-le sur votre système.
mkfs.xfs -i size=1024 -s size=4096 /dev/md0
mount /dev/md0 /mnt
df -hT
#Si un disque membre de la matrice RAID est en panne, reconfigurez RAID 1 comme suit après avoir échangé un nouveau disque.
mdadm --manage /dev/md0 --add /dev/sdc1







