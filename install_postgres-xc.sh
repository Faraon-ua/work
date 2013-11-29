#!/bin/bash
#Directory where all binaries for Postgres-xc will reside
install_dir="$HOME/postgresxc-install/"

#install prerequiries for Postgres-xc
sudo echo -e "\e[34mInstalling prerequiries\e[0m"
sudo apt-get install libreadline-dev libpcap-dev zlib1g-dev bison flex wget tar make


sudo echo -e "\e[34mDownloading Postgres-xc\e[0m"
wget http://downloads.sourceforge.net/project/postgres-xc/Version_1.1/pgxc-v1.1.tar.gz
#unpack downsloaded tar
tar -xvf pgxc-v1.1.tar.gz

echo -e "\e[34mPostgres-xc install directory is $install_dir\e[0m"

echo -e "\e[34mInstalling Postgres-xc\e[0m"

#installing Postgres-xc
cd postgres-xc
./configure --prefix=$install_dir
make
sudo make install

read -p "Press any key to quit..."
exit
