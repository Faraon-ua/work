#!/bin/bash
#create a new system user so Postgres-xc processes are runned under this user
username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"

echo -n "Please enter ACTIVE(or current) GTM host and press ENTER: "
read gtm_host
echo -n "Please enter Datanode name and press ENTER: "
read datanode_name
echo -n "Please enter Coordinator name and press ENTER: "
read coordinator_name

#check if user was previously created
echo -e "\e[34mChecking if $username exists\e[0m"

id $username &> /dev/null
if [ $? -eq 0 ]; then
	echo -e "\e[34m$username already exists\e[0m"
else
#if not - create user and set up his password with user prompt
	echo -e "\e[34mCreating user $username \e[0m"
	sudo useradd -d $user_dir -m -G sudo $username

	echo -e "\e[34mPlease enter the password for user $username:\e[0m"
	read -s password1
	echo -e "\e[34mPlease repeat the password:\e[0m"
	read -s password2

	#Check both passwords match
	if [ $password1 != $password2 ]; then
		echo -e "\e[91mPasswords do not match\e[0m"
		read -p "Press enter to quit..."
		exit   
	fi

	#Change password
	echo -e "$password1\n$password1\n" | sudo passwd $username   
fi

cd $user_dir
sudo -u $username mkdir pgxc
cd pgxc

####################################################################### GTM

#create directory structure for running GTM
if [ ! -d "gtm" ]; then
	sudo -u $username mkdir gtm

	echo -e "\e[34mInitializing GTM server\e[0m"
	sudo -u $username $install_dir/bin/initgtm -Z gtm -D $user_dir/pgxc/gtm
	#initgtm creates template configuration file for gtm. For details, please visit http://postgres-xc.sourceforge.net/docs/1_0/app-initgtm.html document page.

	#set up basic configuration: name and port number to the configuration file, gtm.conf.
	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/gtm/gtm.conf <<- EOF
	nodename = 'gtm'
	listen_addresses = '*'
	port = 2002
	EOF
	"
fi

echo -e "\e[32mGTM server launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep gtm"

#starting GTM server
sudo -u postgresxc $install_dir/bin/gtm_ctl -Z gtm -D $user_dir/pgxc/gtm -l gtm.log start

####################################################################### GTM_PROXY


#gtm_proxy_name="gtm_proxy$HOSTNAME"
#create directory structure for running GTM_PROXY
#if [ ! -d "gtm_proxy" ]; then
#	sudo -u $username mkdir gtm_proxy
#
#	echo -e "\e[34mInitializing GTM_PROXY server\e[0m"
#	sudo -u postgresxc $install_dir/bin/initgtm -Z gtm_proxy -D /home/postgresxc/pgxc/gtm_proxy
#	#initgtm creates template configuration file for gtm. For details, please visit http://postgres-xc.sourceforge.net/docs/1_0/app-initgtm.html document page.
#
#	#set up basic configuration: name and port number to the configuration file, gtm.conf.
#	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/gtm_proxy/gtm_proxy.conf <<- EOF
#	nodename = '$gtm_proxy_name'
#	listen_addresses = '*'
#	port = 2001
#	gtm_port = 2002
#	gtm_host = '$gtm_host'
#	EOF
#	"
#fi

#echo -e "\e[32mGTM PROXY server launching\e[0m"
#echo "You can check it running in terminal:# sudo netstat -lp | grep gtm"
#echo "Press Ctrl+C to stop GTM server"

#starting GTM PROXY server
#sudo -u postgresxc $install_dir/bin/gtm_ctl -Z gtm_proxy -D /home/postgresxc/pgxc/gtm_proxy -l gtmproxylog.txt start


####################################################################### DATANODE


if [ ! -d "datanode" ]; then
	sudo -u $username mkdir datanode

	echo -e "\e[34mInitializing DATANODE\e[0m"
	sudo -u $username $install_dir/bin/initdb --nodename=$datanode_name -D $user_dir/pgxc/datanode
	#initdb creates template datanode and creates initial database called postgres. 

	#Add several lines of configuration parameters to postgresql.conf file. 
	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/datanode/postgresql.conf <<- EOF
	listen_addresses = '*'
	gtm_port = 2002
	gtm_host = '$gtm_host'
	port = 2006
	EOF
	"	

	#edit pg_hba.conf files to accept connections from other servers (192.168.1.x network ip addresses) 
	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/datanode/pg_hba.conf <<- EOF
	host all all 0.0.0.0/0 trust
	EOF
	"
fi

echo -e "\e[32mDATANODE launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

#start datanode
sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/datanode -Z datanode -l $user_dir/pgxc/datanode/data.log

####################################################################### COORDINATOR


if [ ! -d "coordinator" ]; then
	sudo -u $username mkdir coordinator

	echo -e "\e[34mInitializing COORDINATOR\e[0m"
	sudo -u $username $install_dir/bin/initdb --nodename=$coordinator_name -D $user_dir/pgxc/coordinator
	#initdb creates template coordinator and creates initial database called postgres. 
	
	#Add several lines of configuration parameters to postgresql.conf file. Pooler_port is another port number which every coordinator needs. (datanode port)
	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/coordinator/postgresql.conf <<- EOF
	pgxc_node_name = '$coordinator_name'
	listen_addresses = '*'
	gtm_port = 2002
	gtm_host = '$gtm_host'
	port = 2004
	pooler_port = 2006
	EOF
	"

	#edit pg_hba.conf files to accept connections from other servers (192.168.1.x network ip addresses) 
	sudo -u postgresxc bash -c "cat > $user_dir/pgxc/coordinator/pg_hba.conf <<- EOF
	host all all 0.0.0.0/0 trust
	EOF
	"
fi

echo -e "\e[32mCOORDINATOR launching\e[0m"
echo "You can check it running in terminal:# sudo netstat -lp | grep postgres"

#start coordinator
sudo -u postgresxc $install_dir/bin/pg_ctl start -D $user_dir/pgxc/coordinator -Z coordinator -l $user_dir/pgxc/coordinator/coord.log
