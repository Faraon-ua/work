pgxc_username="postgresxc"
user_dir="/home/$pgxc_username"
install_dir="$HOME/postgresxc-install"

sudo -u $username $install_dir/bin/gtm_ctl promote -Z gtm -D $user_dir/pgxc/gtm
