# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # p1jenkins server
  config.vm.define "p1jenkins-pipeline" do |p1jenkins|
    p1jenkins.vm.box = "debian/buster64"
    p1jenkins.vm.hostname = "p1jenkins-pipeline"
    p1jenkins.vm.box_url = "debian/buster64"
    p1jenkins.vm.network :private_network, ip: "192.168.5.2"
    p1jenkins.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 3072]
      v.customize ["modifyvm", :id, "--name", "p1jenkins-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config    
      service ssh restart
    SHELL
    p1jenkins.vm.provision "shell", path: "install_p1jenkins.sh"
  end
end




