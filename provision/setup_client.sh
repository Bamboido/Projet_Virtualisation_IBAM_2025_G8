# Installer Node Exporter pour Prometheus
# Télécharger la dernière version de Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

# Extraire l'archive téléchargée
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz

# Déplacer le binaire vers un répertoire accessible dans le PATH
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

# Créer un utilisateur pour exécuter Node Exporter sans privilégier les droits root
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