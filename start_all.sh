#!/bin/bash
#create a new system user so Postgres-xc processes are runned under this user
username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"

####################################################################### GTM

echo -e "\e[32mGTM server launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep gtm"

#starting GTM server
sudo -u postgresxc $install_dir/bin/gtm_ctl -Z gtm -D $user_dir/pgxc/gtm -l gtm.log start

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

