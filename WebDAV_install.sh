#!/bin/bash
# author: Phuc-Hai Huynh
# decription: the bash to install WebDAV

sudo echo "Start installing..."
# 1. Active the WebDAV
line_number=$(grep -nix '#Include /private/etc/apache2/extra/httpd-dav.conf' /etc/apache2/httpd.conf | cut -d: -f1 -)
if [ "$line_number" != "" ]; then
	cp -n /etc/apache2/httpd.conf ~/Desktop/backup-httpd.conf  
	sed "$line_number s/^#//" /etc/apache2/httpd.conf > ~/Desktop/new-httpd.conf   
	sudo mv ~/Desktop/new-httpd.conf /etc/apache2/httpd.conf
	sudo chown root:wheel /etc/apache2/httpd.conf
fi
#2. Edit the httpd-dav.conf
cp -n /etc/apache2/extra/httpd-dav.conf ~/Desktop/backup-httpd-dav.conf
cp -n /etc/apache2/extra/httpd-dav.conf ~/Desktop/new-httpd-dav.conf
line_number=$(grep -nix '</Directory>' /etc/apache2/extra/httpd-dav.conf | cut -d: -f1 - | tail -n 1)
line_number=$((line_number+1))
echo "Alias /webdav \"/Library/WebServer/WebDAV\"
<Directory \"/Library/WebServer/WebDAV\">
  Dav On
  Order Allow,Deny
  Allow from all
  AuthType Basic
  AuthName WebDAV-Realm
  AuthUserFile \"/usr/webdav.passwd\"
  <LimitExcept GET OPTIONS>
    require user YourUserName
  </LimitExcept>
</Directory>
" > tmp
while read line 
do
	sed -e "$line_number a\\
$line" ~/Desktop/new-httpd-dav.conf > $$ && mv $$ ~/Desktop/new-httpd-dav.conf
	line_number=$((line_number+1)) 
done < tmp
rm tmp
#3. Setup user and password
echo -n "Enter user name: "; read UserName
sed "s/YourUserName/$UserName/" ~/Desktop/new-httpd-dav.conf > $$ && mv $$ ~/Desktop/new-httpd-dav.conf
sudo mv ~/Desktop/new-httpd-dav.conf /etc/apache2/extra/httpd-dav.conf
sudo chown root:wheel /etc/apache2/extra/httpd-dav.conf
sudo htpasswd -c /usr/webdav.passwd $UserName
sudo mkdir -p /Library/WebServer/WebDAV
sudo mkdir -p /usr/var
sudo chown -R www:www /Library/WebServer/WebDAV
sudo chown -R www:www /usr/var
sudo chgrp www /usr/webdav.passwd