Vagrant.configure("2") do |config|
	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "4"]
		vb.gui = false
	  end
	config.vm.box = "bento/ubuntu-20.04"
#	config.vm.box = "bento/ubuntu"
	config.vm.network "public_network"
	config.vm.provision "apt-get update", type: "shell", inline: "echo apt-get update; apt-get update"
	config.vm.provision "docker", type: "shell", inline: "echo Installing docker; apt-get install -y docker.io"
#	config.vm.provision "docker-compose", type: "shell", inline: "echo Installing docker-compose; apt-get install -y docker-compose"
#	config.vm.provision "mkdir", type: "shell", inline: "mkdir ~/teamcity && mkdir ~/teamcity/data && mkdir ~/teamcity/logs && chmod -R 777 ~/teamcity"
#	config.vm.provision "chmod", type: "shell", inline: "chmod ~/teamcity 777 -r"
#	config.vm.provision "chmod for agent", type: "shell", inline: "mkdir ~/teamcity/agent && chmod -R 777 ~/teamcity/agent"
#	config.vm.provision "docker compose up", type: "shell", inline: "cd /vagrant/teamcity && docker-compose up"
	
	#	config.vm.provision "cd", type: "shell", inline: "cd /vagrant/Wordpress"
	config.vm.provision "install python3-pip", type: "shell", inline: "echo apt install python3-pip; apt install python3-pip -y"
	config.vm.provision "install ansible", type: "shell", inline: "echo install ansible; pip3 install ansible "
	
 end
