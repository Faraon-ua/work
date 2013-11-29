#!/bin/bash

#user who was creating the cluster
pgxc_username="postgresxc"
user_dir="/home/$pgxc_username"

#directory where postgres-xc executables reside (e.g. /home/alex/postgresxc-install/)
install_dir="$HOME/postgresxc-install"

while echo $1 | grep ^- > /dev/null; do
    eval $( echo $1 | sed 's/-//g' | tr -d '\012')=$2
    shift
    shift
done

NEWGTM=$newgtm

#kill all postgres processes except GTM (we need it to be promoted)
ps -ef | grep postgres | grep -v grep | grep -v gtm | awk '{print $2}' | sudo xargs kill -9

#change configuration files
coordStr=`sudo -u postgresxc head -1 $user_dir/pgxc/coordinator/postgresql.conf`
sudo -u postgresxc bash -c "cat > $user_dir/pgxc/coordinator/postgresql.conf <<- EOF
	$coordStr
	listen_addresses = '*'
	gtm_port = 2002
	gtm_host = '$NEWGTM'
	port = 2004
	pooler_port = 2006
	EOF
	"
sudo -u postgresxc bash -c "cat > $user_dir/pgxc/datanode/postgresql.conf <<- EOF
	listen_addresses = '*'
	gtm_port = 2002
	gtm_host = '$NEWGTM'
	port = 2006
	EOF
	"

#!!!!!!!!!!!!!!!!here before starting all postgres services you need to promote NEWGTM (run promoteGTM.sh on the NEWGTM server)


####################################################################### STARTING DATANODE

echo -e "\e[32mDATANODE launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/datanode -Z datanode -l $user_dir/pgxc/datanode/data.log

####################################################################### STARTING COORDINATOR

echo -e "\e[32mCOORDINATOR launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/coordinator -Z coordinator -l $user_dir/pgxc/coordinator/coord.log

#how to launch
#./switchLocalPg -newgtm #HOSTNAME

