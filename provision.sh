#!/usr/bin/env bash
set -e

#
# Vagrant bootstrap file for building development environment.
#

# Create symlink to vagrant document root for given project.
PROJECT_ROOT="vagrant"
#ln -nsfv /vagrant /$PROJECT_ROOT

# Create project variables
DB_NAME="develop"
DB_USER="root"
DB_PASS=""
DB_DUMP="/$PROJECT_ROOT/db/latest.sql"

# Generate provision files to prevent rebuilding every time.
VAGRANT_PROVISION_FIRST="/$PROJECT_ROOT/tmp/vagrant-provision.first"
VAGRANT_PROVISION_DONE="/$PROJECT_ROOT/tmp/vagrant-provision.done"

# If this is a brand new VM, override provisioning.done
if ! [ -f $VAGRANT_PROVISION_FIRST ]; then
	rm -f $VAGRANT_PROVISION_DONE
fi

if [ -f $VAGRANT_PROVISION_DONE ]; then
	echo -e "Box is already provisioned. Delete the $VAGRANT_PROVISION_DONE file to rebuild on vagrant up."

	# for some reason the httpd daemon is not starting on boot, though
	# it's configured to, so just boot it here.
	echo "Restarting services."
	/etc/init.d/nginx restart
	/etc/init.d/httpd stop
	/etc/init.d/php-fpm restart
	/etc/init.d/mysql restart
	/etc/init.d/memcached restart
	/etc/init.d/redis restart
	exit 0;
fi

# Update base box
echo "Updating current software."
yum -y update

# Install missing repos
echo "Installing repos for epel, IUS, Percona, nginx."
rpm -Uhv http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/epel-release-6-5.noarch.rpm
rpm -Uhv http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
cp /$PROJECT_ROOT/yum/nginx.repo /etc/yum.repos.d/nginx.repo

# Install all software needed for machine
PHP_VERSION="php54"
echo "Installing base software."

PHP_OPCODE_VERSION="$PHP_VERSION-pecl-apc"
if [ $PHP_VERSION == "php55u" ]; then
	PHP_OPCODE_VERSION="$PHP_VERSION-opcache"
fi;

yum -y groupinstall "Development Tools"
yum -y install \
zlib-devel vim-common vim-enhanced vim-minimal htop mytop nmap at yum-utils \
openssl openssl-devel curl libcurl libcurl-devel lsof tmux bash-completion \
weechat gpg rpm-build rpm-devel autoconf automake lynx gcc httpd httpd-devel \
mod_ssl mod_fcgid mod_geoip memcached memcached-devel nginx \
$PHP_VERSION \
$PHP_VERSION-devel $PHP_VERSION-common $PHP_VERSION-gd $PHP_VERSION-imap \
$PHP_VERSION-mbstring $PHP_VERSION-mcrypt $PHP_VERSION-mhash \
$PHP_VERSION-mysql $PHP_VERSION-pear $PHP_VERSION-pecl-memcache \
$PHP_VERSION-pecl-memcache-debuginfo $PHP_VERSION-pecl-xdebug \
$PHP_VERSION-xml $PHP_VERSION-pdo $PHP_VERSION-fpm $PHP_OPCODE_VERSION \
$PHP_VERSION-pecl-redis redis \
Percona-Server-client-56 Percona-Server-server-56

#echo 'Updating old repo software to new repo software.'
#yum -y remove git
#yum -y install git18

# SPDY depends on "at" and "httpd"
echo "Installing SPDY..."
rpm -U https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm

# Installing PHP composer...
echo "Installing Composer."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# SSH
echo -e "Copying Vagrant SSH keys."
mkdir ~/.ssh
cp /$PROJECT_ROOT/scripts/ssh/vagrant* ~/.ssh/
cp /$PROJECT_ROOT/scripts/ssh/config ~/.ssh
chmod 600 ~/.ssh/*

# Installing PECL Scrypt extension for PHP...
echo "Installing PECL Scrypt extension for PHP."
pecl install scrypt

# Installing PECL Http 1.7.6 extension for PHP...
echo "Installing PECL Http 1.7.6 extension for PHP."
pecl install http://pecl.php.net/get/pecl_http-1.7.6.tgz

echo "Adding services to boot."
chkconfig nginx on
chkconfig httpd off
chkconfig mysql on
chkconfig php-fpm on
chkconfig memcached on
chkconfig redis on
chkconfig iptables off
chkconfig ip6tables off

# Start services
echo "Starting/stopping services."
/etc/init.d/nginx start
/etc/init.d/httpd stop
/etc/init.d/mysql start
/etc/init.d/php-fpm start
/etc/init.d/memcached start
/etc/init.d/redis start
/etc/init.d/iptables stop
/etc/init.d/ip6tables stop

echo "Waiting for Percona MySQL."
while ! service mysql status | grep -q running; do
	sleep 1
done

# Set database user and import tables
echo "Setting up DB, and granting all privileges to '$DB_USER'@'%'."
mysql -u $DB_USER --password="$DB_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION"
mysql -u $DB_USER --password="$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME"
mysql -u $DB_USER --password="$DB_PASS" $DB_NAME < /$PROJECT_ROOT/db/latest.sql

# Append httpd.conf
#echo "Appending httpd.conf file"
#bash -c "echo 'Include /vagrant/sites/*.httpd.conf' >> /etc/httpd/conf/httpd.conf"
echo "Symlinking httpd and nginx vhosts files."
ln -nsfv /vagrant/httpd/develop.vagrant.dev.httpd.conf /etc/httpd/conf.d
rm -rf /etc/nginx/conf.d/*.conf
ln -nsfv /vagrant/nginx/develop.vagrant.dev.nginx.conf /etc/nginx/conf.d

# Append httpd.conf file to autoload vhosts for Develop
echo "Loading vhosts for $PROJECT_ROOT"
# Move unnecessary default configs into bak directories.
mkdir /etc/httpd/conf.d/bak /etc/nginx/conf.d/bak
mv /etc/httpd/conf.d/*.conf /etc/httpd/conf.d/bak/
mv /etc/nginx/conf.d/*.conf /etc/nginx/conf.d/bak/
ln -nsfv /$PROJECT_ROOT/include/config/httpdconf/dev/vhosts/*.conf /etc/httpd/conf.d/
#bash -c "echo 'Include /develop/include/config/httpdconf/dev/vhosts/*.conf' >> /etc/httpd/conf/httpd.conf"
# Remember Listen 80 in main config interrupts project configs.

# Give permissions to fcgid wapper.
echo -e "Giving php.fcgi 777 permissions."
chmod 777 /$PROJECT_ROOT/include/config/httpdconf/dev/fastcgi/php.fcgi

# Restart httpd for new configs and fcgid wrapper
/etc/init.d/httpd restart

# Clear previous dependencies, if any.
rm -rf /$PROJECT_ROOT/include/vendor

# Install project dependencies.
#echo -e "Installing composer dependencies."
#(cd /develop/include && php /usr/local/bin/composer install)

# Install scrypt wrapper for project.
#echo -e "Cloning php-scrypt library."
#git clone git@github.com:DomBlack/php-scrypt.git /$PROJECT_ROOT/include/vendor/php-scrypt

# Install dotfiles
#echo -e "Installing Dane MacMillan's dotfiles."
#git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh

# Generate install files to prevent reinstalls.
echo -e "Cleaning install."
touch $VAGRANT_PROVISION_FIRST
touch $VAGRANT_PROVISION_DONE
yum -y clean all

echo -e "\nProvisioning complete!"
echo -e "\n=============================="
echo "$PROJECT_ROOT provisioning complete."
echo "DB:"
echo " - User: '$DB_USER'@'%'"
echo " - Pass: $DB_PASS"
echo " - Addr: 192.168.33.10"
echo " - Port: guest 3306 -> host 3306"
echo "Web:"
echo " - guest *:80 -> host 80"
echo " - guest *:443 -> host 443"
echo " "
echo "Remember to set host's host files to"
echo "match (NameVirtualHost +) ServerName."
echo " "
echo -e "\n Dotfiles (for better shell usage): "
echo -e "git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh"
echo "==============================\n"
# to change hostname
# vi /etc/sysconfig/network
# HOSTNAME=develop.dev
# hostname develop.dev
# vi /etc/hosts
# 192.168.33.19 develop.dev
# /etc/init.d/network restart

#to change to httpd worker
#/etc/sysconfig/httpd
#uncomment the worker line.
