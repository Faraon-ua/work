username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"

echo -n "Please enter ACTIVE GTM host and press ENTER: "
read gtm_host

#stop gtm
sudo -u $username $install_dir/bin/gtm_ctl stop -Z gtm -D $user_dir/pgxc/gtm

cd $user_dir
sudo -u $username mkdir pgxc
cd pgxc
if [ ! -d "gtm" ]; then
	sudo -u $username mkdir gtm
	#init if was not inited before
	sudo -u $username $install_dir/bin/initgtm -Z gtm -D $user_dir/pgxc/gtm
fi

#change config

sudo -u postgresxc bash -c "cat /dev/null > $user_dir/pgxc/gtm/gtm.conf"
sudo -u postgresxc bash -c "cat >> $user_dir/pgxc/gtm/gtm.conf << EOF
nodename = 'gtm'
listen_addresses = '*'
port = 2002
startup = STANDBY
active_host = '$gtm_host'
active_port = 2002
EOF"

#start gtm standby
#sudo -u $username $install_dir/bin/gtm_ctl start -Z gtm -D $user_dir/pgxc/gtm
sudo -u $username $install_dir/bin/gtm -D $user_dir/pgxc/gtm

