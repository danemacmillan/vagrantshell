#!/usr/bin/env bash
## Develop with errors on.
#set -e

#
# Vagrant bootstrap file for building development environment.
#

# Set SELinux to permissive mode
# This is done because for a virtual environment, we do not want SELINUX to be
# overriding permissions.
# TODO read this: http://nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/
echo -e "Setting selinux enforcing to permissive mode."
setenforce 0

# Create symlink to vagrant document root for given project.
PROJECT_ROOT="vagrant"

# Create empty develop dir in sites/
PROJECT_VHOST_DIR="develop"
mkdir -pv /vagrant/sites/$PROJECT_VHOST_DIR
cp /vagrant/sites/phpinfo.php /vagrant/sites/$PROJECT_VHOST_DIR/index.php
#ln -nsfv /vagrant-$PROJECT_VHOST_DIR /vagrant/sites/$PROJECT_VHOST_DIR

# Create project variables
USER_USER="vagrant"
USER_GROUP=$USER_USER
DB_NAME="develop"
DB_USER="root"
DB_PASS=""

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
yum -y install kernel kernel-devel
yum -y update

# Install missing repos
echo "Installing repos for epel, IUS, Percona, nginx."
rpm -Uhv http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/epel-release-6-5.noarch.rpm
rpm -Uhv http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
cp -rf /$PROJECT_ROOT/yum/nginx.repo /etc/yum.repos.d/nginx.repo

# Install all software needed for machine
PHP_VERSION="php54"
echo "Installing base software."

PHP_OPCODE_VERSION="$PHP_VERSION-pecl-apc"
if [ $PHP_VERSION == "php55u" ]; then
	PHP_OPCODE_VERSION="$PHP_VERSION-opcache"
fi;

yum -y groupinstall "Development Tools"
yum -y install \
zlib-devel vim vim-common vim-enhanced vim-minimal htop mytop nmap at yum-utils \
openssl openssl-devel curl libcurl libcurl-devel lsof tmux bash-completion \
weechat gpg rpm-build rpm-devel autoconf automake lynx gcc httpd httpd-devel \
mod_ssl mod_fcgid mod_geoip memcached memcached-devel nginx npm \
$PHP_VERSION \
$PHP_VERSION-devel $PHP_VERSION-common $PHP_VERSION-gd $PHP_VERSION-imap \
$PHP_VERSION-mbstring $PHP_VERSION-mcrypt $PHP_VERSION-mhash \
$PHP_VERSION-mysql $PHP_VERSION-pear $PHP_VERSION-pecl-memcache \
$PHP_VERSION-pecl-memcache-debuginfo $PHP_VERSION-pecl-xdebug \
$PHP_VERSION-xml $PHP_VERSION-pdo $PHP_VERSION-fpm $PHP_OPCODE_VERSION \
$PHP_VERSION-pecl-redis redis \
Percona-Server-client-56 Percona-Server-server-56

# SPDY depends on "at" and "httpd"
echo "Installing SPDY..."
rpm -U https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm

# Installing PHP composer...
echo "Installing Composer."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# SSH
echo -e "Copying Vagrant SSH keys."
mkdir -pv ~/.ssh
mkdir -pv /home/$USER_USER/.ssh
cp -rf /$PROJECT_ROOT/ssh/* ~/.ssh/
cp -rf /$PROJECT_ROOT/ssh/* /home/$USER_USER/.ssh/

# Permissions
echo -e "Setting permissions for $USER_USER:$USER_GROUP and root:root."
chown -R $USER_USER:$USER_GROUP /home/$USER_USER
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 700 /home/$USER_USER/.ssh
chmod 600 /home/$USER_USER/.ssh/*

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

# Set database user credentials
echo "Setting up DB, and granting all privileges to '$DB_USER'@'%'."
mysql -u $DB_USER --password="$DB_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION"
mysql -u $DB_USER --password="$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME"

# Append httpd.conf
#echo "Appending httpd.conf file"
#bash -c "echo 'Include /vagrant/httpd/*.httpd.conf' >> /etc/httpd/conf/httpd.conf"

echo -e "Symlinking httpd and nginx vhosts files."
# Move unnecessary default configs into bak directories.
mkdir -pv /etc/httpd/conf.d/bak /etc/nginx/conf.d/bak
mv /etc/nginx/conf.d/*.conf /etc/nginx/conf.d/bak/
# apache
ln -nsfv /$PROJECT_ROOT/httpd/develop.vagrant.dev.httpd.conf /etc/httpd/conf.d
# nginx
ln -nsfv /$PROJECT_ROOT/nginx/vagrant.dev.nginx.conf /etc/nginx/conf.d
ln -nsfv /$PROJECT_ROOT/nginx/develop.vagrant.dev.nginx.conf /etc/nginx/conf.d

# Give permissions to fcgid wapper.
#echo -e "Giving php.fcgi 777 permissions."
#chmod 777 /$PROJECT_ROOT/include/config/httpdconf/dev/fastcgi/php.fcgi

# Restart httpd for new configs and fcgid wrapper
echo -e "Restarting servers to use vhost configs."
/etc/init.d/httpd stop
/etc/init.d/nginx restart
/etc/init.d/php-fpm restart

# Git update. Note: git2u may change with IUS repo.
echo -e 'Updating Git.'
yum -y remove git && yum -y install git2u

# Set permissions on regular user.
echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
chown -R $USER_USER:$USER_GROUP /home/$USER_USER

# Set permissions on /vagrant
# Note: since moving to CentOS 6.6 basebox, the permissions have not worked by
# default, so nginx could not read
# This was done before realizing selinux setenforce 1 was responsible.
#echo -e "Setting permissions on /$PROJECT_ROOT"
#chmod -R 764 /$PROJECT_ROOT

# Generate install files to prevent reinstalls.
echo -e "Cleaning install."
touch $VAGRANT_PROVISION_FIRST
touch $VAGRANT_PROVISION_DONE
yum -y clean all

echo -e "\n\nProvisioning complete!"
echo -e "--------------------------------------------------------------------------------"
echo "$PROJECT_ROOT provisioning complete."
echo -e "\nDB:"
echo "   User: '$DB_USER'@'%'"
echo "   Pass: $DB_PASS"
echo "   Addr: 192.168.80.80"
echo "   Port: guest 3306 -> host 3306"
echo -e "\nWeb:"
echo "   guest :80 -> host :80"
echo "   guest :443 -> host :443"
echo -e "\nSSH:"
echo "   User: $USER_USER"
echo "   Group: $USER_GROUP"
echo "   root access: 'sudo su'"
echo "   guest :22 -> host :4444"
echo -e "\nRemember to set /etc/hosts (or C:\Windows\System32\Drivers\etc\hosts):"
echo "   192.168.80.80 develop.vagrant.dev"
echo -e "\nFor any questions: Dane MacMillan <work@danemacmillan.com>"
echo -e "This vagrant box was provisioned using: https://github.com/danemacmillan/vagrantshell"
echo -e "--------------------------------------------------------------------------------"
echo " "
echo " "

# Post-provision
# --------------

# Import sql files
DB_DUMP=/$PROJECT_ROOT/post-provision/*.sql
shopt -s nullglob
for dbdump in $DB_DUMP
do
	if [[ -f "$dbdump" ]]; then
		echo -e "Importing sql file into DB $DB_NAME: $dbdump"
		mysql -u $DB_USER --password="$DB_PASS" $DB_NAME < "$dbdump"
		echo " "
	fi
done

# Execute scripts
# Note: dotfiles are installed in post-provision
POST_PROVISION=/$PROJECT_ROOT/post-provision/*.sh
shopt -s nullglob
for pp in $POST_PROVISION
do
	if [[ -f "$pp" ]]; then
		echo -e "Running post-provision script: $pp"
		source "$pp"
		echo " "
	fi
done











# to change hostname
# vi /etc/sysconfig/network
# HOSTNAME=vagrant.dev
# hostname vagrant.dev
# vi /etc/hosts
# 192.168.80.80 develop.vagrant.dev
# /etc/init.d/network restart

#to change to httpd worker
#/etc/sysconfig/httpd
#uncomment the worker line.
