Vagrant.configure("2") do |config|
  # Base de Données Maître
  config.vm.define "db-master" do |master|
    master.vm.box = "ubuntu/bionic64"
    master.vm.hostname = "db-master"
    master.vm.network "private_network", ip: "192.168.56.13"
	
	master.vm.provision "shell", path: "provision/setup_db_master.sh"    
  end

	# Base de Données Esclave
	config.vm.define "db-slave" do |slave|
	  slave.vm.box = "ubuntu/bionic64"
	  slave.vm.hostname = "db-slave"
	  slave.vm.network "private_network", ip: "192.168.56.14"
	  slave.vm.provision "shell", path: "provision/setup_db_slave.sh"
	end
  # Serveur web1 Apache/PHP
  config.vm.define "web1" do |web|
    web.vm.box = "ubuntu/bionic64"
    web.vm.hostname = "web1"
    web.vm.network "private_network", ip: "192.168.56.11"
    web.vm.provision "shell", path: "provision/setup_web.sh" 
  end
  
  # Serveur web2 Apache/PHP
  config.vm.define "web2" do |web|
    web.vm.box = "ubuntu/bionic64"
    web.vm.hostname = "web2"
    web.vm.network "private_network", ip: "192.168.56.12"
    web.vm.provision "shell", path: "provision/setup_web.sh" 
  end
  
  #EQUILIBREUR DE CHARGE
  config.vm.define "lb" do |lb|
	lb.vm.box = "ubuntu/bionic64"
	lb.vm.hostname = "lb"	
    lb.vm.network "private_network", ip: "192.168.56.10"	
    lb.vm.network "forwarded_port", guest: 80, host: 8080
    lb.vm.provision "shell", path: "provision/setup_lb.sh"
  end
  
  #MACINE CLIENTE
  config.vm.define "client" do |client|
	client.vm.box = "ubuntu/bionic64"
    client.vm.network "private_network", ip: "192.168.56.16"
	client.vm.hostname = "client"	
    client.vm.provision "shell", path: "provision/setup_client.sh"	
  end
  
  #SERVEUR DE MONITORING
  config.vm.define "monitoring" do |monitoring|
	monitoring.vm.box = "ubuntu/bionic64"
    monitoring.vm.network "private_network", ip: "192.168.56.15"
	monitoring.vm.hostname = "monitoring"
    monitoring.vm.provision "shell", path: "provision/setup_monitoring.sh"
  end
  
end
