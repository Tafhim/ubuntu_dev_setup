# A bootstrap script to run after finishin Ubuntu installation
 Installs most of the stuff needed for development
 Place java*.tar.gz and netbeans installer script, update the filenames

* Note, after running the scipt, do the following *
[As root] open the file /etc/dhcp/dhcclient.conf,
find the string "# option domain-name-servers 127.0.0.1"
erase the "#" in front of it and save
then execute 
# dnsmasq start
