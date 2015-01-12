#!/usr/bin/env bash
# Install dotfiles
# Redirect stdout to /dev/null because vim vundler runs some semi-interactive
# installer, which screws with terminal buffer.
echo -e "\nInstalling dotfiles from https://github.com/danemacmillan/dotfiles. This will take a minute."
echo -e "--------------------------------------------------------------------------------"
echo -e "Installing for '$USER_USER' user..."
# http://fixunix.com/suse/255347-bash-dev-null-permission-denied-problem-keeps-happening.html
rm -f /dev/null
mknod -m 0666 /dev/null c 1 3
su $USER_USER -c "cd /home/$USER_USER && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh 1> /dev/null"
# Set permissions on regular user.
echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
chown -R $USER_USER:$USER_GROUP /home/$USER_USER
echo -e "Installing for 'root' user..."
rm -f /dev/null
mknod -m 0666 /dev/null c 1 3
cd /root && git clone git@github.com:danemacmillan/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh 1> /dev/null
echo -e "\ndotfiles installed successfully!"
