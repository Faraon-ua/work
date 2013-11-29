#!/bin/bash

username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
promoteFile="promoteGtm.sh"
reconfFile="stop_reconfigureGTM_start.sh"
#startallFile="start_all.sh"
startallWithoutGtmFile="start_all_without_gtm.sh"

#sudo apt-get install sshpass

PASSWORD=pokein2013
#PASSWORD=PokeIn2013
NEWGTM=$2
USERNAME=$3
HOSTS=$1

#kill and reconfigure newgtm
	sleep 5	

	echo "reconfiguring files at $NEWGTM"

	chmod +x $DIR/$reconfFile
	sshpass -p $PASSWORD scp $DIR/$reconfFile $USERNAME@${NEWGTM}:~/
	sshpass -p $PASSWORD ssh -t $USERNAME@${NEWGTM} /home/$USERNAME/$reconfFile $NEWGTM

#kill and reconfigure hosts
for HOSTNAME in ${HOSTS} ; do
	sleep 5

	echo "reconfiguring files at $HOSTNAME"

	chmod +x $DIR/$reconfFile
	sshpass -p $PASSWORD scp $DIR/$reconfFile $USERNAME@${HOSTNAME}:~/
	sshpass -p $PASSWORD ssh -t $USERNAME@${HOSTNAME} /home/$USERNAME/$reconfFile $NEWGTM
done

#promote
echo "promoting $NEWGTM as new GTM server"
chmod +x $DIR/$promoteFile
sshpass -p $PASSWORD scp $DIR/$promoteFile $USERNAME@${NEWGTM}:~/
sshpass -p $PASSWORD ssh -t $USERNAME@${NEWGTM} /home/$USERNAME/$promoteFile


	#start all processes on newgtm
	sleep 5

	echo "processes before start at $NEWGTM"

	chmod +x $DIR/$startallWithoutGtmFile
	sshpass -p $PASSWORD scp $DIR/$startallWithoutGtmFile $USERNAME@${NEWGTM}:~/
	sshpass -p $PASSWORD ssh -t $USERNAME@${NEWGTM} /home/$USERNAME/$startallWithoutGtmFile

#start all processes on hosts
for HOSTNAME in ${HOSTS} ; do
	sleep 5

	echo "processes before start at $HOSTNAME"

	chmod +x $DIR/$startallWithoutGtmFile
	sshpass -p $PASSWORD scp $DIR/$startallWithoutGtmFile $USERNAME@${HOSTNAME}:~/
	sshpass -p $PASSWORD ssh -t $USERNAME@${HOSTNAME} /home/$USERNAME/$startallWithoutGtmFile
done

echo "processes started"

ps -A --sort -cmd > ~/postgres-xc/processes4.log
sudo netstat --listen > ~/postgres-xc/port4.log

echo "processes logged"

#./remoteCall.sh "nubuntu1.cloudapp.net nubuntu2.cloudapp.net" nubuntu1.cloudapp.net azureuser
#./remoteCall.sh "192.168.1.150" 192.168.1.200 alex
#param1 - all hosts except NEWGTM
#param2 - NEWGTM host
#param3 - username for ssh connection
#coment

