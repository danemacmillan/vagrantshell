vagrantshell
============

Vagrant Box Provisioned Using Shell

---

This is a vagrant box provisioned using bash shell scripting as the provisioner.
There will come a time when `saltstack` or `ansible` will be used, but before that happens, work
needs to be done. That will also exist in a different repo.

---

# Install VirtualBox

If you have OSX, just use `brew`, otherwise have a look here:

https://www.virtualbox.org/wiki/Downloads

# Install Vagrant

If you have OSX, just use `brew`, otherwise have a look here:

https://docs.vagrantup.com/v2/installation/

https://www.vagrantup.com/downloads.html

# Install guest additions plugin

`vagrant plugin install vagrant-vbguest`

https://github.com/dotless-de/vagrant-vbguest

If you are on Windows and this does not work, just move on.

# Provision

1. Navigate to the directory you want to work from.

2. `git clone git@github.com:danemacmillan/vagrantshell.git` or `git clone https://github.com/danemacmillan/vagrantshell.git` (if you do not have SSH keys).

3. `cd` into it.

4. `vagrant up` where `VagrantFile` exists.

5. Wait for everything to install. This can take about ten minutes, depending on the connection.

# Log in

From the directory with the `VagrantFile`, run `vagrant ssh`. You're in.

# Edit hosts file

This is necessary so that the environment can be accessed in a browser. Edit
`/etc/hosts` to include the following line:

`192.168.80.80 develop.vagrant.dev`

On Windows machine, the file is located at `C:\Windows\System32\Drivers\etc\hosts`.

# Access from Web browser

Browse to the address at `develop.vagrant.dev` using `HTTP` or `HTTPS`. This
will work so long as the hosts file has been updated.

# Development

By default, the server parses documents from `/vagrant/sites/develop`. You can
create additional vhosts under `/vagrant/sites` to test different codebases. On
your host machine, go to `/your/local/path/sites/develop` to make changes.

# Post-provision

Read the `README.md` in `post-provision` to see how post-provision scripts and
DB imports work.

# Dependencies

This vagrant provision includes the following dotfiles:

https://github.com/danemacmillan/dotfiles

It is installed during post-provision.
