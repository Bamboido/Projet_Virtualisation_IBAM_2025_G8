#!/bin/bash

# Mise à jour des paquets
sudo apt-get update

# Installer Prometheus
sudo apt-get install -y prometheus

# Installer Grafana
sudo apt-get install -y software-properties-common

# Ajouter la clé GPG de Grafana
sudo wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Ajouter le dépôt de Grafana
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update

# Installer Grafana
sudo apt-get install -y grafana

# Démarrer les services
sudo systemctl start prometheus
sudo systemctl enable prometheus

sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Créer un fichier de configuration pour Prometheus pour collecter les métriques de tous les serveurs
cat <<EOL | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'web1'
    static_configs:
      - targets: ['192.168.56.11:9100']

  - job_name: 'web2'
    static_configs:
      - targets: ['192.168.56.12:9100']

  - job_name: 'db-master'
    static_configs:
      - targets: ['192.168.56.13:9100']

  - job_name: 'db-slave'
    static_configs:
      - targets: ['192.168.56.14:9100']

  - job_name: 'lb'
    static_configs:
      - targets: ['192.168.56.10:9100']

  - job_name: 'client'
    static_configs:
      - targets: ['192.168.56.16:9100']


EOL

# Redémarrer Prometheus pour appliquer la nouvelle configuration
sudo systemctl restart prometheus

sudo ufw allow 9090

# Vérifier que Prometheus collecte bien les métriques
curl http://localhost:9090/targets

# Grafana - Ajouter Prometheus comme source de données
# On peut automatiser l'ajout de Prometheus à Grafana via l'API de Grafana
# Assurez-vous que Grafana est bien démarré
sleep 10

curl -X POST -H "Content-Type: application/json" -d '{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://localhost:9090",
  "access": "proxy",
  "isDefault": true
}' http://admin:admin@localhost:3000/api/datasources

# Ajouter un tableau de bord ou configuration supplémentaire dans Grafana si nécessaire
# Vous pouvez ici utiliser l'API de Grafana pour créer un tableau de bord par défaut (par exemple)
# ou configurer les panneaux automatiquement.

