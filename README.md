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

# Provision

1. Navigate to the directory you want to work from.

2. Clone this repo.

3. `cd` into it.

4. `vagrant up`

5. Have a drink.

# Log in

From the directory with the `VagrantFile`, run `vagrant ssh`. You're in.

# Edit hosts file

This is necessary so that the environment can be accessed in a browser. Edit
`/etc/hosts` to include the following line:

`192.168.80.80 develop.vagrant.dev`

On Windows machine, the file is located at `C:\Windows\System32\Drivers\etc\hosts`.

Browse to the address at `develop.vagrant.dev` using `HTTP` or `HTTPS`.
