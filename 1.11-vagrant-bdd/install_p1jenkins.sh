#!/bin/bash

## install p1jenkins

IP=$(hostname -I | awk '{print $2}')

echo "START - install jenkins - "$IP

echo "[1]: install utils & ansible"
apt-get update -qq >/dev/null
apt-get install -qq -y git sshpass wget ansible gnupg2 curl >/dev/null


echo "[2]: install java & jenkins"
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -qq >/dev/null
apt-get install -qq -y default-jre jenkins >/dev/null
systemctl enable jenkins
systemctl start jenkins


echo "[2]: ansible custom"
sed -i 's/.*pipelining.*/pipelining = True/' /etc/ansible/ansible.cfg
sed -i 's/.*allow_world_readable_tmpfiles.*/allow_world_readable_tmpfiles = True/' /etc/ansible/ansible.cfg

echo "[3]: install docker & docker-composer"
curl -fsSL https://get.docker.com | sh; >/dev/null
usermod -aG docker jenkins # authorize docker for jenkins user
curl -sL "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose 

echo "[4]: use registry without ssl"
echo "
{
 \"insecure-registries\" : [\"192.168.5.5:5000\"]
}
" >/etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

echo "END - install jenkins"

