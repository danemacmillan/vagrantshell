#!/usr/bin/env bash
# Install dotfiles
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
