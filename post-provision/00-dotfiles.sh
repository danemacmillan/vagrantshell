#!/usr/bin/env bash
# Install dotfiles
echo -e "\nInstalling dotfiles from https://github.com/danemacmillan/dotfiles. This will take a minute."
echo -e "--------------------------------------------------------------------------------"
echo -e "Installing for 'root' user..."
cd /root && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh > /dev/null 2>&1
echo -e "Installing for '$USER_USER' user..."
su $USER_USER -c "cd /home/$USER_USER && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh > /dev/null 2>&1"
# Set permissions on regular user.
echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
chown -R $USER_USER:$USER_GROUP /home/$USER_USER
echo -e "\ndotfiles installed successfully!"
