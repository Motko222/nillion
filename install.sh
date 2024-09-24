#!/bin/bash


cd ~
sudo apt update
sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
docker pull nillion/verifier:$VERSION
mkdir -p ~/nillion/accuser
docker run -v ~/nillion/accuser:/var/tmp nillion/verifier:$VERSION initialise
sudo cat ~/nillion/accuser/credentials.json
