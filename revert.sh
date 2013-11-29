#!/bin/bash

username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
promoteFile="promoteGtm.sh"
reconfFile="stop_reconfigureGTM_start.sh"
startallFile="start_all.sh"

PASSWORD=pokein2013

kill_script='sudo pkill -9 -f postgres'
HOSTS=$1

echo -n "Please enter GTM host to be Active: "
read NEWGTM
echo -n "Please enter hosts username: "
read USERNAME

#kill and reconfigure hosts
for HOSTNAME in ${HOSTS} ; do
	chmod +x $DIR/$reconfFile
	sshpass -p $PASSWORD ssh -t $USERNAME@${HOSTNAME} $kill_script
	
	#sshpass -p $PASSWORD scp $DIR/$reconfFile $USERNAME@${HOSTNAME}:~/
	#sshpass -p $PASSWORD ssh -t $USERNAME@${HOSTNAME} /home/$USERNAME/$reconfFile $NEWGTM
done

<<com
#start all processes on hosts
for HOSTNAME in ${HOSTS} ; do

	echo "processes before start at $HOSTNAME"

	chmod +x $DIR/$startallFile
	sshpass -p $PASSWORD scp $DIR/$startallFile $USERNAME@${HOSTNAME}:~/
	sshpass -p $PASSWORD ssh -t $USERNAME@${HOSTNAME} /home/$USERNAME/$startallFile
done
com

#./revert.sh "nubuntu1.cloudapp.net nubuntu2.cloudapp.net" nubuntu1.cloudapp.net azureuser
#./revert.sh "192.168.1.150 192.168.1.200"
