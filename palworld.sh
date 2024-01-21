i9k/# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

sudo apt update && sudo apt upgrade -y 
sudo apt install unzip apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -y
sudo apt update

#install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

#create random string for password
VHPW=$(echo $RANDOM | md5sum | head -c 20)

#get stackname created by user data script and update SSM parameter name with this to make it unique
STACKNAME=$(</tmp/mcParamName.txt)
PARAMNAME=mcValheimPW-$STACKNAME

#put random string into parameter store as encrypted string value
aws ssm put-parameter --name $PARAMNAME --value $VHPW --type "SecureString" --overwrite


#install docker and valheim app on docker
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt install docker-compose -y
sudo usermod -aG docker $USER
sudo mkdir /usr/games/serverconfig
cd /usr/games/serverconfig
sudo bash -c 'echo "version: \"3\"
version: '3.1'
services:
   palworld:
      image: eli9k/mypalserver
      restart: unless-stopped
      container_name: palworld-server
      ports:
        - 8211:8211/udp
        - 27015:27015/udp
      environment:
         - PORT=8211
         - PLAYERS=4
         - MULTITHREADING=FALSE
         - COMMUNITY=false  # Enable this if you want your server to show up in the community servers tab, USE WITH SERVER_PASSWORD!
         # Enable the environment variables below if you have COMMUNITY=true
         # - SERVER_PASSWORD="worldofpals"
         # - SERVER_NAME="World of Pals"
         # - ADMIN_PASSWORD="someAdminPassword"
      volumes:
         - /path/to/your/palworld/folder:/palworld/
echo "@reboot root (cd /usr/games/serverconfig/ && docker-compose up)" > /etc/cron.d/awsgameserver
sudo docker-compose up
