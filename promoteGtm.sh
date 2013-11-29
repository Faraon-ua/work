username="postgresxc"
user_dir="/home/$username"
install_dir="$HOME/postgresxc-install"

ps -A --sort -cmd > procBeforePromote.log
sudo netstat --listen > portBeforePromote.log

sudo -u $username $install_dir/bin/gtm_ctl promote -Z gtm -D $user_dir/pgxc/gtm

ps -A --sort -cmd > procAfterPromote.log
sudo netstat --listen > portAfterPromote.log

