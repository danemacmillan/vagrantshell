#!/usr/bin/env bash
## Develop with errors on.
#set -e

#
# Vagrant bootstrap file for building development environment.
#

PROJECT_ROOT="vagrant"

# Create new project directory in sites/
PROJECT_VHOST_DIR="develop.vagrant.dev"
if [[ ! -d /vagrant/sites/$PROJECT_VHOST_DIR ]]; then
	mkdir -pv /vagrant/sites/$PROJECT_VHOST_DIR
	cp /vagrant/sites/phpinfo.php /vagrant/sites/$PROJECT_VHOST_DIR/index.php
fi

# Create project variables
USER_USER="vagrant"
USER_GROUP=$USER_USER
DB_NAME="develop"
DB_USER="root"
DB_PASS=""

# Add vagrantshell bin to path
#chmod -R +x /$PROJECT_ROOT/bin
#export PATH="/$PROJECT_ROOT/bin:$PATH"

# Generate provision files to prevent rebuilding every time.
VAGRANT_PROVISION_FIRST="/$PROJECT_ROOT/tmp/vagrant-provision.first"
VAGRANT_PROVISION_DONE="/$PROJECT_ROOT/tmp/vagrant-provision.done"

# If this is a brand new VM, override provisioning.done
if ! [ -f $VAGRANT_PROVISION_FIRST ]; then
	rm -f $VAGRANT_PROVISION_DONE
fi

if [ -f $VAGRANT_PROVISION_DONE ]; then
	echo -e "Box is already provisioned. Delete the $VAGRANT_PROVISION_DONE file to rebuild on vagrant up."

	# for some reason the nginx daemon is not starting on boot, though
	# it's configured to, so just boot it here.
	echo "Restarting services."
	/etc/init.d/nginx restart
	/etc/init.d/php-fpm restart
	/etc/init.d/mysql restart
	/etc/init.d/memcached restart
	/etc/init.d/redis restart
	exit 0;
fi

# Set timezone
mv /etc/localtime /etc/localtime.bak
ln -nsfv /usr/share/zoneinfo/EST5EDT /etc/localtime

# Update base box
echo "Updating current software."
yum -y update

# Install missing repos
echo "Installing repos for epel, IUS, Percona, nginx."
rpm -Uhv --nosignature http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/epel-release-6-5.noarch.rpm
rpm -Uhv --nosignature http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-14.ius.centos6.noarch.rpm
rpm -Uhv --nosignature http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
rpm -Uhv --nosignature http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
rpm -Uhv --nosignature https://repo.varnish-cache.org/redhat/varnish-3.0.el6.rpm
rpm -Uhv --nosignature http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

# Switch to mainline Nginx version in repo file.
sed -i -e 's/packages\/centos/packages\/mainline\/centos/g' /etc/yum.repos.d/nginx.repo

# Install all software needed for machine
echo "Installing base software."
PHP_VERSION="php55u"

# Smaller footprint. 66M downloaded.
yum -y groupinstall "Development Tools"

# Install some essentials. 165MB downloaded.
yum -y install \
vim vim-common vim-enhanced vim-minimal htop mytop nmap at wget yum-utils \
openssl openssl-devel curl libcurl libcurl-devel lsof tmux bash-completion \
gpg lynx memcached memcached-devel nginx npm pv parted ca-certificates \
setroubleshoot atop autofs bind-utils tuned cachefilesd symlinks varnish \
$PHP_VERSION \
$PHP_VERSION-devel $PHP_VERSION-common $PHP_VERSION-gd $PHP_VERSION-imap \
$PHP_VERSION-mbstring $PHP_VERSION-mcrypt $PHP_VERSION-mhash \
$PHP_VERSION-mysql $PHP_VERSION-pear $PHP_VERSION-pecl-memcached \
$PHP_VERSION-pecl-memcached-debuginfo $PHP_VERSION-pecl-xdebug \
$PHP_VERSION-xml $PHP_VERSION-pdo $PHP_VERSION-fpm $PHP_VERSION-opcache \
$PHP_VERSION-cli $PHP_VERSION-pecl-jsonc $PHP_VERSION-devel \
$PHP_VERSION-pecl-geoip $PHP_VERSION-pecl-redis redis \
$PHP_VERSION-pecl-mongo mongodb mongodb-server \
Percona-Server-client-56 Percona-Server-server-56 \
percona-toolkit percona-xtrabackup mysql-utilities mysqlreport mysqltuner \

# This will be 1.2GB downloaded.
# Install groups of software. Some of the essentials below will already be
# included in these groups, but in case you ever want to shrink the size of the
# install, these can be removed. "Development Tools" should always be installed.
#yum -y --setopt=group_package_types=mandatory,default,optional groupinstall \
#"Base" "Development Tools" "Console internet tools" "Debugging Tools" \
#"Networking Tools" "Performance Tools"

# Essentials for compiling a number of projects, but mostly unnecessary for Web.
#yum -y install \
#zlib-devel cmake expect lua rpm-build rpm-devel autoconf automake gcc \
#svn cpp make libtool patch gcc-c++ boost-devel mysql-devel pcre-devel \
#gd-devel libxml2-devel expat-devel libicu-devel bzip2-devel oniguruma-devel \
#openldap-devel readline-devel libc-client-devel libcap-devel binutils-devel \
#pam-devel elfutils-libelf-devel ImageMagick-devel libxslt-devel libevent-devel \
#libcurl-devel libmcrypt-devel tbb-devel libdwarf-devel

# Clean yum
yum clean all

# Ensure nginx's terrible default configs are blown away.
rm -rf /etc/nginx/conf.d

# Map configs into core.
source /vagrant/bin/vshell map

# Set SELinux to permissive mode for Nginx
# This is done because for a virtual environment, we do not want SELINUX to be
# overriding permissions.
# TODO read this: http://nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/
#echo -e "Setting SELinux enforcing of Nginx policy to permissive mode."
#semanage permissive -a httpd_t
echo -e "Disabling SELinux."
setenforce 0
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux

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

# Generating new one for those with zero knowledge of how this works. This can
# be automatically renamed to id_rsa in a post-provision script.
ssh-keygen -b 4096 -f /home/$USER_USER/.ssh/vagrantshell.id_rsa -C vagrantshell@4096_`date +%Y-%m-%d-%H%M%S` -N ""

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

# Tuning
tuned-adm profile latency-performance
cachefilesd -f /etc/cachefilesd.conf
modprobe cachefiles
service cachefilesd start

echo "Adding services to boot."
chkconfig nginx on
chkconfig mysql on
chkconfig php-fpm on
chkconfig memcached on
chkconfig redis on
chkconfig iptables off
chkconfig ip6tables off
chkconfig cachefilesd on
chkconfig mongod on

# Start services
echo "Starting/stopping services."
/etc/init.d/nginx restart
/etc/init.d/mysql restart
/etc/init.d/php-fpm restart
/etc/init.d/memcached restart
/etc/init.d/redis restart
/etc/init.d/iptables stop
/etc/init.d/ip6tables stop
/etc/init.d/cachefilesd start
/etc/init.d/mongod restart

echo "Waiting for Percona MySQL."
while ! service mysql status | grep -q running; do
	sleep 1
done
# Set database user credentials
echo "Setting up DB, and granting all privileges to '$DB_USER'@'%'."
mysql -u $DB_USER --password="$DB_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION"
mysql -u $DB_USER --password="$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME"

# Update rsync
echo -e "Updating rsync."
yum -y remove rsync && yum -y install rsync31u

# Git update. Note: git2u may change with IUS repo.
echo -e 'Updating Git.'
yum -y remove git && yum -y install git2u

# Symlink vshell utility into PATH for root and vagrant users.
echo -e "Add vshell utility to PATH."
if [[ ! -d "$HOME/bin" ]]; then
	mkdir -pv "$HOME/bin"
fi
ln -s /vagrant/bin/vshell $HOME/bin
if [[ ! -d "/home/$USER_USER/bin" ]]; then
	mkdir -pv "/home/$USER_USER/bin"
fi
ln -s /vagrant/bin/vshell /home/$USER_USER/bin

# Set permissions on regular user.
echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
chown -R $USER_USER:$USER_GROUP /home/$USER_USER

# Generate install files to prevent reinstalls.
echo -e "Cleaning install."
touch $VAGRANT_PROVISION_FIRST
touch $VAGRANT_PROVISION_DONE
yum -y clean all

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo -e "\n\nProvisioning complete!"
echo -e "--------------------------------------------------------------------------------"
echo "$PROJECT_ROOT provisioning complete."
echo -e "\nDB:"
echo "   User: '$DB_USER'@'%'"
echo "   Pass: $DB_PASS"
echo "   DBName: $DB_NAME"
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
echo "   192.168.80.80 vagrant.dev develop.vagrant.dev"
echo -e "\nFor any questions: Dane MacMillan <work@danemacmillan.com>"
echo -e "This vagrant box was provisioned using: https://github.com/danemacmillan/vagrantshell"
echo -e "--------------------------------------------------------------------------------"
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
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
		mysql -u $DB_USER --password="$DB_PASS" -f $DB_NAME < "$dbdump"
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

# Extra

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

# Append httpd.conf
#echo "Appending httpd.conf file"
#bash -c "echo 'Include /vagrant/httpd/*.httpd.conf' >> /etc/httpd/conf/httpd.conf"

# Give permissions to fcgid wapper.
#echo -e "Giving php.fcgi 777 permissions."
#chmod 777 /$PROJECT_ROOT/include/config/httpdconf/dev/fastcgi/php.fcgi
