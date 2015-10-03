#!/usr/bin/env bash
echo -e "\nInstalling VM dev tools."
echo -e "--------------------------------------------------------------------------------"
echo -e "Creating dev site (https://dev)"
if [[ ! -d /vagrant/sites/dev ]]; then
	mkdir -pv /vagrant/sites/dev
fi
echo -e "Adding phpinfo"
cp /vagrant/sites/phpinfo.php /vagrant/sites/dev/
echo -e "Symlinking sites listing"
ln -s /vagrant/sites /vagrant/sites/dev/sites
echo -e "Symlinking logs"
ln -s /vagrant/logs /vagrant/sites/dev/logs
echo -e "Installing linux-dash"
cd /vagrant/sites/dev && git clone https://github.com/afaqurk/linux-dash.git

echo -e "\nInstalling xhprof and xhgui to https://dev/xhgui"
echo -e "--------------------------------------------------------------------------------"
echo "Installing xhprof."
pecl install channel://pecl.php.net/xhprof-0.9.4
echo "Booting mongodb."
sudo /etc/init.d/mongod restart
echo "Installing xhgui."
cd /vagrant/sites/dev && git clone https://github.com/perftools/xhgui.git
cd /vagrant/sites/dev/xhgui && php install.php
cp /vagrant/sites/dev/xhgui/config/config.default.php /vagrant/sites/dev/xhgui/config/config.php
