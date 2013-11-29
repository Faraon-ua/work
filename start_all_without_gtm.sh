#!/bin/bash
#create a new system user so Postgres-xc processes are runned under this user
username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"
current_ip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

ps -A --sort -cmd > procBeforeStarting.log
sudo netstat --listen > portBeforeStarting.log

#sudo rm $user_dir/pgxc/coordinator/postmaster.pid
#sudo rm $user_dir/pgxc/datanode/postmaster.pid

####################################################################### DATANODE

echo -e "\e[32mDATANODE launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

#start datanode
sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/datanode -Z datanode -l $user_dir/pgxc/datanode/data.log

####################################################################### COORDINATOR

echo -e "\e[32mCOORDINATOR launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

#start coordinator
sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/coordinator -Z coordinator -l $user_dir/pgxc/coordinator/coord.log

sleep 5

ps -A --sort -cmd > procAfterStarting.log
sudo netstat --listen > portAfterStarting.log


