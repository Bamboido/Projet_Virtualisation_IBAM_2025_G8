# Mettre à jour les paquets et installer Nginx
sudo apt-get update
sudo apt-get install -y nginx

# Configuration de Nginx pour équilibrer la charge
cat <<EOL > /etc/nginx/sites-available/default
# Définir le groupe de serveurs avec les adresses IP de web1 et web2
upstream web_servers {
    server 192.168.56.11:80;  # Adresse IP de web1
    server 192.168.56.12:80;  # Adresse IP de web2
}

server {
    listen 80;

    location / {
        proxy_pass http://web_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

# Vérifier la configuration de Nginx avant de redémarrer
sudo nginx -t

# Si la configuration est correcte, redémarrer Nginx pour appliquer les changements
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
else
    echo "Erreur dans la configuration de Nginx. L'équilibrage de charge n'a pas pu être configuré."
fi

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
