<VirtualHost *:80>
	VirtualDocumentRoot "__USER_HOME__/workspace/php/projects/%1"
	ServerName vhosts.dev
	ServerAlias *.dev
	UseCanonicalName Off
	LogFormat "%V %h %l %u %t \"%r\" %s %b" vcommon
	ErrorLog "__USER_HOME__/workspace/php/projects/vhosts-error_log"
	<Directory "__USER_HOME__/workspace/php/projects/*">
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		Allow from all
		RewriteEngine On
		RewriteBase /
	</Directory>
</VirtualHost>
