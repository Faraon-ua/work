#!/bin/bash

xc_username="postgresxc"
user_dir="/home/$xc_username"
install_dir="$HOME/postgresxc-install"

NEWGTM=$1

#stop postgres and gtm
#sudo -u postgresxc $install_dir/bin/pg_ctl stop -D $user_dir/pgxc/coordinator -Z coordinator
#sudo -u postgresxc $install_dir/bin/pg_ctl stop -D $user_dir/pgxc/datanode -Z datanode
#sudo -u postgresxc $install_dir/bin/gtm_ctl -D $user_dir/pgxc/gtm -Z gtm stop

ps -A --sort -cmd > procBeforeKilling.log
sudo netstat --listen > portBeforeKilling.log

ps -ef | grep postgres | grep -v grep | grep -v gtm | awk '{print $2}' | sudo xargs kill -9

ps -A --sort -cmd > procAfterKilling.log
sudo netstat --listen > portAfterKilling.log

#sudo pkill -9 -f gtm
#sudo rm $user_dir/pgxc/coordinator/postmaster.pid
#sudo rm $user_dir/pgxc/datanode/postmaster.pid
#sudo rm $user_dir/pgxc/gtm/gtm.pid

echo newgtm=$NEWGTM

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

#echo "restarting datanode and coordinator"
#echo "sudo -u postgresxc $install_dir/bin/pg_ctl -D $user_dir/pgxc/datanode  -Z datanode -l $user_dir/pgxc/datanode/data.log restart"
#echo "sudo -u postgresxc $install_dir/bin/pg_ctl -D $user_dir/pgxc/coordinator -Z coordinator -l $user_dir/pgxc/coordinator/coord.log restart"

#sudo -u postgresxc $install_dir/bin/gtm_ctl -D $user_dir/pgxc/gtm -Z gtm -l $user_dir/pgxc/gtm/gtm.log start
#sudo -u postgresxc $install_dir/bin/pg_ctl -D $user_dir/pgxc/datanode -Z datanode -l $user_dir/pgxc/datanode/data.log start
#sudo -u postgresxc $install_dir/bin/pg_ctl -D $user_dir/pgxc/coordinator -Z coordinator -l $user_dir/pgxc/coordinator/coord.log start


