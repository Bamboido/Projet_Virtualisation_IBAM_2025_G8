# Mettre à jour les paquets
sudo apt-get update

# Installer MySQL
sudo apt-get install -y mysql-server

# Configurer le serveur esclave
sudo sed -i '/\[mysqld\]/a server-id=2' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '/\[mysqld\]/a log_bin=/var/log/mysql/mysql-bin.log' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '/\[mysqld\]/a relay_log=/var/log/mysql/mysql-relay-bin.log' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '/\[mysqld\]/a log_slave_updates=1' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i '/\[mysqld\]/a read_only=1' /etc/mysql/mysql.conf.d/mysqld.cnf

# Redémarrer MySQL pour appliquer les changements
sudo systemctl restart mysql

# Importer le dump de la base de données maître
sudo mysql -u root -p'vagrant' < /vagrant/master_dump.sql

# Configurer la connexion au serveur maître
sudo mysql -e "CHANGE MASTER TO MASTER_HOST='192.168.56.13', MASTER_USER='repl', MASTER_PASSWORD='vagrant', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=4;"

# Démarrer la réplication
sudo mysql -e "START SLAVE;"

# Vérifier l'état de la réplication
sudo mysql -e "SHOW SLAVE STATUS\G"

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
