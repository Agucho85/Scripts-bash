#!/bin/bash

#users=('ignacio.rubio' 'agustin.manessi' 'diego.miguel')

#sudo groupadd sshusers
#sudo usermod -aG sshusers ec2-user

#for user in ${users[@]}; do
adduser $1
usermod -aG wheel,sshusers $1
mkdir /home/$1/.ssh/
touch /home/$1/.ssh/authorized_keys
while read -r line; do echo $line >> /home/$1/.ssh/authorized_keys; done < $1.pub
chmod 700 /home/$1/.ssh/
chmod 600 /home/$1/.ssh/authorized_keys
chown -R $1:$1 /home/$user/.ssh/
#sudo echo "Dirmod2022!" | passwd "$1" --stdin
#done

#sudo echo "AllowGroups sshusers" >> /etc/ssh/sshd_config
#sudo systemctl restart sshd
