# Mettre à jour les paquets
sudo apt-get update

# Installer MySQL
sudo apt-get install -y mysql-server

# Configurer la base de données
sudo mysql -e "CREATE DATABASE projet_vagrant;"
sudo mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'vagrant';"
sudo mysql -e "GRANT ALL PRIVILEGES ON projet_vagrant.* TO 'admin'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Créer la table étudiant
sudo mysql -e "USE projet_vagrant; CREATE TABLE etudiant (
  matricule INT PRIMARY KEY,
  nom VARCHAR(50),
  prenom VARCHAR(50)
);"

# Modifier bind-address pour accepter les connexions distantes
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# Activer le log binaire et configurer l'ID du serveur pour la réplication
sudo sed -i "/\[mysqld\]/a log_bin=mysql-bin" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "/\[mysqld\]/a server-id=1" /etc/mysql/mysql.conf.d/mysqld.cnf

# Redémarrer MySQL pour appliquer les changements
sudo systemctl restart mysql

# Créer un utilisateur dédié à la réplication
sudo mysql -e "CREATE USER 'repl'@'%' IDENTIFIED BY 'vagrant';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Verrouiller les tables pour effectuer un dump de la base de données
sudo mysql -e "FLUSH TABLES WITH READ LOCK;"
sudo mysqldump -u root -pvagrant \
  --databases projet_vagrant \
  --routines --events --flush-logs \
  --master-data=2 --single-transaction \
  > /vagrant/master_dump.sql
sudo mysql -e "UNLOCK TABLES;"

# Installer Node Exporter pour Prometheus
# Télécharger la dernière version de Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

# Extraire l'archive téléchargée
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz

# Déplacer le binaire vers un répertoire accessible dans le PATH
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

# Créer un utilisateur pour exécuter Node Exporter sans privilèges root
sudo useradd --no-create-home --shell /bin/false node_exporter

# Créer un service systemd pour démarrer Node Exporter automatiquement
echo "[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/node_exporter.service

# Recharger les unités systemd et activer Node Exporter pour démarrer au boot
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
