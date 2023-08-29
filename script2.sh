#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

#install services and apps
apt-get update
apt-get install -y joe acl git

debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
apt-get -y install mysql-server mysql-client
apt-get -y install unzip

#install apache
apt-get install -y apache2

#install php 7
add-apt-repository ppa:ondrej/php
apt-get -y update
apt-get -y install php7.0
apt-get -y install php7.0-mysql
apt-get -y install php7.0-mcrypt
apt-get -y install php7.0-mbstring
apt-get -y install php7.0-memcache
apt-get -y install php7.0-xmlrpc
apt-get -y install php7.0-xsl
apt-get -y install libapache2-mod-php7.0
apt-get -y install language-pack-UTF-8
a2enmod php7.0
apt-get -y install php7.0-curl
apt-get -y install php7.0-gd


#set virtualhost file to sites-available and enable site
cp -rf /var/www/vagrant-dependencies/vagrant.conf /etc/apache2/sites-available/000-default.conf
a2enmod rewrite
service apache2 restart
apachectl restart

#create DB
mysql -u root -pvagrant -e "CREATE DATABASE vagrant"