#!/bin/bash

# Mettre à jour les paquets
sudo apt-get update

# Installer Apache, PHP et le module MySQL
sudo apt-get install -y apache2 php libapache2-mod-php php-mysql

# Déployer l'application web avec le nom d'hôte affiché
echo "<?php
  // Connexion à la base de données MySQL
  \$conn = new PDO('mysql:host=192.168.56.13;dbname=projet_vagrant', 'admin', 'vagrant');
  \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  
  // Insertion de données dans la base de données
  if (isset(\$_POST['submit'])) {
    \$stmt = \$conn->prepare('INSERT INTO etudiant (matricule, nom, prenom) VALUES (:matricule, :nom, :prenom)');
    \$stmt->execute(['matricule' => \$_POST['matricule'], 'nom' => \$_POST['nom'], 'prenom' => \$_POST['prenom']]);
  }
  
  // Sélection des données à afficher
  \$stmt = \$conn->query('SELECT * FROM etudiant');
  \$data = \$stmt->fetchAll();
  
  // Récupérer le nom d'hôte de la machine
  \$hostname = gethostname();  
  \$ip = \$_SERVER['SERVER_ADDR'];
?>
<!DOCTYPE html>
<html>
<head>
  <title>Gestion Étudiants</title>
</head>
<body>
  <h1>Ajouter un étudiant</h1>
  <form method='POST'>
    <label>Matricule :</label> <input type='text' name='matricule' required><br>
    <label>Nom :</label> <input type='text' name='nom' required><br>
    <label>Prénom :</label> <input type='text' name='prenom' required><br>
    <input type='submit' name='submit' value='Ajouter'>
  </form>
  
  <h1>Liste des étudiants</h1>
  <table border='1'>
    <tr><th>Matricule</th><th>Nom</th><th>Prénom</th></tr>
    <?php foreach (\$data as \$row) { echo '<tr><td>'.\$row['matricule'].'</td><td>'.\$row['nom'].'</td><td>'.\$row['prenom'].'</td></tr>'; } ?>
  </table>
  
  <!-- Afficher le nom d'hôte de la machine -->
  <h2>Vous êtes sur le serveur : <?php echo \$hostname; ?> (IP : <?php echo \$ip; ?>)</h2>
</body>
</html>" | sudo tee /var/www/html/index.php

# Redémarrer Apache pour appliquer les changements
sudo systemctl restart apache2

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

