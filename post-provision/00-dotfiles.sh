#!/usr/bin/env bash
# Install dotfiles
# Redirect stdout to /dev/null because vim vundler runs some semi-interactive
# installer, which screws with terminal buffer.
# There are bizarre /dev/null permission errors when redirecting to it with su -c
echo -e "\nInstalling dotfiles from https://github.com/danemacmillan/dotfiles. This will take a minute."
echo -e "--------------------------------------------------------------------------------"
echo -e "Installing for '$USER_USER' user..."
su $USER_USER -c "cd /home/$USER_USER && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh"
# Set permissions on regular user.
#echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
#chown -R $USER_USER:$USER_GROUP /home/$USER_USER
echo -e "Installing for 'root' user..."
#cd /root && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh 1> /dev/null
cd /root && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh
echo -e "\ndotfiles installed successfully!"
