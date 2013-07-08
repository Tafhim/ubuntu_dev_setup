#! /bin/sh
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

if [ -z "$1" ]; then
	echo "Usage $0 user_name"
	exit 1
fi

USER=$1
USER_HOME="/home/$USER"

apt-get install git zsh vim aria2 awesome curl chromium-browser mpd ncmpcpp git conky
# Sublime setup
#if [ ! -f $USER_HOME/Downloads/sublime-text_build-3047_amd64.deb ]; then
#	echo "No"
#	curl -O http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3047_amd64.deb
#fi
#dpkg -i sublime-text_build-3047_amd64.deb

# LAMP Stack setup 
apt-get install apache2 apache2-doc apache2-suexec

apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql php5 php-pear php5-sqlite php5-curl php5-imap php5-intl php5-mysql phpmyadmin openssh-server php5-mcrypt
if [ ! -d $USER_HOME/workspace ]; then
	echo "Not found, so creating your workspace"
	if [ -d $PWD/workspace ]; then
		cp -R workspace $USER_HOME/
	else
		mkdir -p $USER_HOME/workspace/php/projects
		mkdir -p $USER_HOME/workspace/php/www
	fi
fi 

chown -R $USER:$USER $USER_HOME/workspace

rm -f /etc/apache2/mods-enabled/vhost_alias.load
ln -s /etc/apache2/mods-available/vhost_alias.load /etc/apache2/mods-enabled/vhost_alias.load
rm -f /etc/apache2/mods-enabled/rewrite.load
ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

sed -e "s#__USER_HOME__#$USER_HOME#" etc/apache2/sites-enabled/001-vhosts.dev.tpl > /etc/apache2/sites-enabled/001-vhosts.dev
sed -e "s#__USER_HOME__#$USER_HOME#" etc/apache2/sites-available/default.tpl > /etc/apache2/sites-available/default 

sed -i -e 's/dns=dnsmasq/#dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
rm -f /etc/resolv.conf
ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
resolvconf --create-runtime-directories
resolvconf --enable-updates

cp -f etc/dnsmasq.conf /etc/dnsmasq.conf
cp -f etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head
echo "UseDNS no" >> /etc/ssh/sshd_config



#sudo mysql_install_db
#sudo /usr/bin/mysql_secure_installation
# java has to be installed
# sudo bash netbeans-7.3-linux.sh