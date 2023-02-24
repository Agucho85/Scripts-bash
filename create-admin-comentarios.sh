#!/bin/bash

#Crear los archivos .pem y .pub con DBeaver; Windows no reconoce el formato cuando se crean con ssh-keygen

#USO: sudo sh create-admin.sh <username> <password> //no usar caracteres especiales en <username>

#Crea el usuario <username>
adduser $1

#Si se le quiere bloquear el uso de shell al usuario <username> crearlo de la siguiente manera
# $ adduser $1 -s /sbin/nologin

#Agrega el usuario al grupo sshusers para que pueda iniciar por SSH.
#En caso de no existir el grupo ejecutar:
# $ sudo groupadd sshusers
# $ usermod -aG sshusers ec2-user //O el usuario por defecto según la ditro...
# $ sudo echo 'AllowGroups sshusers' > /etc/ssh/sshd_config
usermod -aG sshusers $1

#Agrega el usuario <username> a wheel (para poder hacer sudo), o usar grupo sudo para distros basadas en Debian...
usermod -aG wheel $1

#Las siguientes seis lineas agregan la clave públcia del usuario al archivo authorized_keys del usuario <username> y establecen los permisos necesario
mkdir /home/$1/.ssh/
touch /home/$1/.ssh/authorized_keys
while read -r line; do echo $line >> /home/$1/.ssh/authorized_keys; done < $1.pub
chmod 700 /home/$1/.ssh/
chmod 600 /home/$1/.ssh/authorized_keys
chown -R $1:$1 /home/$1/.ssh/

#Sete la contraseña <password> al usuario <username> (no es necesario si no se le permite acceso a shell y sudo)
echo $2 | passwd $1 --stdin

#Elimina el archivo <username>.pub que debe estar en la misma ubicación que este script.
rm -f $1.pub

