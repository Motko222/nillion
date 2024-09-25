#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "New id (e.g. nillion-1) ? " id

cd $path
./stop.sh

cd ~
mv nillion $id 
cp -r ~/$id/accuser ~/$id/verifier
rm -r ~/scripts/nillion

cd ~/scripts
git clone https://github.com/Motko222/nillion-x
mv nillion-x $id
cd $id
chmod +x *.sh
./start.sh

