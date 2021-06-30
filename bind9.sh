#Installez BIND pour configurer le serveur DNS qui résout le nom de domaine ou l'adresse IP. DNS utilise 53 / TCP, UDP.
apt -y install bind9 bind9utils dnsutils
#Configurez BIND 9.
#Dans cet exemple, configurez BIND avec l'adresse IP Grobal [172.16.0.80/29], 
#l'adresse IP privée [10.0.0.0/24], le nom de domaine [srv.world]. Cependant, 
#veuillez remplacer les adresses IP et le nom de domaine par votre propre environnement. (En fait, [172.16.0.80/29] est pour l'adresse IP privée, cependant.)
vi /etc/bind/named.conf
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
#commenter la ligne suivantes
# include "/etc/bind/named.conf.default-zones";
# ajouter les lignes suivantes
include "/etc/bind/named.conf.internal-zones";
include "/etc/bind/named.conf.external-zones";
#dans le fichier 
vi /etc/bind/named.conf.internal-zones
#creer un nouveau
# pour la section interne 
view "internal" {
        match-clients {
                localhost;
                10.0.0.0/24;
        };
        
			# définir la zone pour interne
        zone "srv.world" {
                type master;
                file "/etc/bind/srv.world.lan";
                allow-update { none; };
        };
        # 
			# définir la zone pour interne *note
        zone "0.0.10.in-addr.arpa" {
                type master;
                file "/etc/bind/0.0.10.db";
                allow-update { none; };
        };
        include "/etc/bind/named.conf.default-zones";
};
#dans le fichier 
vi /etc/bind/named.conf.external-zones
#creer un nouveau 
# pour la zone externe 
view "external" {
        match-clients { any; };
        # allow any query
        allow-query { any; };
        # prohibit recursion
        recursion no;
        # set zone for external
        zone "srv.world" {
                type master;
                file "/etc/bind/srv.world.wan";
                allow-update { none; };
        };
        # set zone for external *note
        zone "80.0.16.172.in-addr.arpa" {
                type master;
                file "/etc/bind/80.0.16.172.db";
                allow-update { none; };
        };
};
#Limitez les plages auxquelles vous autorisez l'accès si nécessaire.
vi /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0 s placeholder.

        // forwarders {
        //      0.0.0.0;
        // };
        # plage de requêtes que vous autorisez
        allow-query { localhost; 10.0.0.0/24; };
        # la plage de transfert des fichiers de zone
        #le serveur esclave 172.16.0.80/29; 
        allow-transfer { localhost; 10.0.0.0/24; 172.16.0.80/29;  };
        # plage de récursivité que vous autorisez
        allow-recursion { localhost; 10.0.0.0/24; };
        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        # change if not use IPV6
        listen-on-v6 { none; };
};
#Configurer les zones pour la résolution de noms
#Créez des fichiers de zone que les serveurs résolvent l'adresse IP à partir du nom de domaine.
#Pour la zone interne,
#Dans cet exemple, configurez BIND avec l'adresse interne [10.0.0.0/24], le nom de domaine [srv.world]. 
#Veuillez remplacer les adresses IP et le nom de domaine par votre propre environnement.
vi /etc/bind/srv.world.lan
$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        2019071601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define name server
        IN  NS      dlp.srv.world.
        # define name server's IP address
        IN  A       10.0.0.30
        # define mail exchanger
        IN  MX 10   dlp.srv.world.

# define IP address of the hostname
dlp     IN  A       10.0.0.30


#Pour la zone externe,
#Dans cet exemple, configurez BIND avec l'adresse interne [172.16.0.80/29], le nom de domaine [srv.world]. 
#Veuillez remplacer les adresses IP et le nom de domaine par votre propre environnement.
vi /etc/bind/srv.world.wan
$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        2019071601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define name server
        IN  NS      dlp.srv.world.
        # define name server's IP address
        IN  A       172.16.0.82
        # define mail exchanger
        IN  MX 10   dlp.srv.world.

# define IP address of the hostname
dlp     IN  A       172.16.0.82

#Configurer les zones pour la résolution d'adresse
#Pour la zone interne,
#Dans cet exemple, configurez BIND avec l'adresse interne [10.0.0.0/24], le nom de domaine [srv.world]. 
#Veuillez remplacer les adresses IP et le nom de domaine par votre propre environnement.

vi /etc/bind/0.0.10.db
$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        2019071601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define name server
        IN  NS      dlp.srv.world.
        # define the range of this domain included
        IN  PTR     srv.world.
        IN  A       255.255.255.0

# define hostname of the IP address
30      IN  PTR     dlp.srv.world.
#Pour la zone externe,
#Dans cet exemple, configurez BIND avec l'adresse interne [172.16.0.80/29], 
#le nom de domaine [srv.world]. Veuillez remplacer les adresses IP et le nom de domaine par votre propre environnement.

vi /etc/bind/80.0.16.172.db
$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        2019071601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define name server
        IN  NS      dlp.srv.world.
        # define the range of this domain included
        IN  PTR     srv.world.
        IN  A       255.255.255.248

# define hostname of the IP address
82      IN  PTR     dlp.srv.world.
#Vérifier la résolution
systemctl restart bind9
vi /etc/resolv.conf
# changement d'adresse
domain srv.world
search srv.world
nameserver 10.0.0.30
#Essayez de résoudre le nom ou l'adresse normalement.
dig dlp.srv.world.
#Définir l'enregistrement CNAME
#Si vous souhaitez attribuer un autre nom (alias) à votre hôte, 
#définissez l'enregistrement CNAME dans le fichier de zone.
#on ajoute la ligne suivante dans le fichier
 vi /etc/bind/srv.world.lan
# aliase IN CNAME server's hostname
ftp     IN  CNAME   dlp.srv.world.
#apres 
rndc reload
dig ftp.srv.world.
#Configurer le serveur DNS esclave
#L'exemple suivant montre un environnement dans lequel le DNS maître est [172.16.0.82], 
#le DNS esclave est [slave.example.host].
vi /etc/bind/named.conf.options
#ajoute l'adresse 172.16.0.80/29; 
 allow-transfer { localhost; 10.0.0.0/24; 172.16.0.80/29; };
rndc reload
#Configurez le serveur esclave DNS.
 vi /etc/bind/named.conf.external-zones
# ajouter des paramètres comme suit
        zone "srv.world" {
                type slave;
                masters { 172.16.0.82; };
                file "/etc/bind/slaves/srv.world.wan";
        };

mkdir /etc/bind/slaves
chown bind. /etc/bind/slaves
rndc reload
ls /etc/bind/slaves
srv.world.wan    # fichiers de zone dans le DNS principal viennent d'être transférés


