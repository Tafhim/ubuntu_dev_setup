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

apt-get update
apt-get install git zsh vim aria2 awesome curl chromium-browser mpd ncmpcpp git conky
# # Sublime setup
# #if [ ! -f $USER_HOME/Downloads/sublime-text_build-3047_amd64.deb ]; then
# #	echo "No"
# #	curl -O http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3047_amd64.deb
# #fi
# #dpkg -i sublime-text_build-3047_amd64.deb

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

# Installing java if the file is ready
if [ ! -f $PWD/jdk-7u25-linux-x64.tar.gz ]; then
	echo "Java installation files not present, skipping Java and Nebeans" 
else
	tar -xvf jdk-7u25-linux-x64.tar.gz
	mkdir -p /usr/lib/jvm
	mv ./jdk1.7.0_25 /usr/lib/jvm/jdk1.7.0
	update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0/bin/java" 1
	update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0/bin/javac" 1
	update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0/bin/javaws" 1
	chmod a+x /usr/bin/java
	chmod a+x /usr/bin/javac
	chmod a+x /usr/bin/javaws
	chown -R root:root /usr/lib/jvm/jdk1.7.0
	update-alternatives --config java
	update-alternatives --config javac
	update-alternatives --config javaws
	
	if [ ! -d $USER_HOME/.mozilla/plugins ]; then	
		mkdir $USER_HOME/.mozilla/plugins
	fi
	if [ -d $USER_HOME/.mozilla/plugins ]; then
		ln -s /usr/lib/jvm/jdk1.7.0/jre/lib/amd64/libnpjp2.so $USER_HOME/.mozilla/plugins/
	fi
	if [ -d /usr/lib/chromium-browser/plugins ]; then
		ln -s /usr/lib/jvm/jdk1.7.0/jre/lib/amd64/libnpjp2.so /usr/lib/chromium-browser/plugins/
	fi
	sed -i -e 's/java-\*-sun-1.\*/jdk\*/g' /etc/apparmor.d/abstractions/ubuntu-browsers.d/java
	/etc/init.d/apparmor restart

	chmod +x netbeans-7.3-linux.sh
	./netbeans-7.3-linux.sh
	rm -rf jdk1.7.0
fi



#sudo mysql_install_db
#sudo /usr/bin/mysql_secure_installation
