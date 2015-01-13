vagrantshell
============

This is a Vagrant box provisioned using plain old bash shell scripting. Avoid
this box if you are hip, trendy, or both; they will all laugh at you.

# Who is this for?

This set up is for newcomers to Web development. It is also for veterans
looking to add virtualization to their development toolbelt without being
inundanted by a hefty learning curve that involves a tonne of trendy new
technologies and nomenclatures. This is why Bash is the provisioner. It is
familiar; it is easy to understand. Once familiarity takes hold, I encourage
you to start looking at more advanced build processes.

There will come a time when `saltstack` or `ansible` will be used, but that
will also exist in a different repo.

# Technologies in the build

## Main

- CentOS 6.6
- Nginx 1.6+
- PHP 5.5.*+ (with opcache)
- Percona (MySQL)
- Redis
- MongoDB
- Xdebug (read below)

## Minor

- Git 2.2+
- Rsync 3.1+

## Note

This box is Magento-friendly. The proper variables and rewrites are
included for Magento development. This does not mean only Magento can be
developed on this box. The Magento settings do not change any other type of
development.

---

# Installation

## Install VirtualBox

If you have OSX, just use `brew`, otherwise have a look here:

https://www.virtualbox.org/wiki/Downloads

## Install Vagrant

If you have OSX, just use `brew`, otherwise have a look here:

https://www.vagrantup.com/downloads.html

## Install guest additions plugin

`vagrant plugin install vagrant-vbguest`

https://github.com/dotless-de/vagrant-vbguest

## Edit hosts file

This is necessary so that the environment can be accessed in a browser. Edit
`/etc/hosts` to include the following line:

`192.168.80.80 dev develop.vagrant.dev`

On Windows, the file is located at `C:\Windows\System32\Drivers\etc\hosts`.

## Provisioning

1. Navigate to the directory you want to work from.

2. `git clone git@github.com:danemacmillan/vagrantshell.git` or `git clone https://github.com/danemacmillan/vagrantshell.git` (if you do not have SSH keys).

3. `cd` into it.

4. Copy any post-provision scripts or SQL dumps into `post-provision`. These
will be files used to build the actual project you want to develop. Without
these, the vagrantshell will just be a hosting environment ready to start new
projects.

5. `vagrant up` where `VagrantFile` exists.

6. Wait for everything to install. This can take about ten minutes, depending on the connection.

## Log in

From the `vagrantshell` directory that contains the `VagrantFile` file, run
`vagrant ssh`. You are in CentOS 6.6 as user, `vagrant`. For root access,
type, `sudo su`.

---

# Development

A default root directory of `develop` will be created in `sites`. There is a
vhost entry which will serve any content within.

By default, the server parses documents from `/vagrant/sites/develop`. You can
create additional sites under `/vagrant/sites` to test different codebases. Be
sure a corresponding vhost entry exists. On your host machine, go to
`/your/local/path/sites/develop` to make changes.

## Access from Web browser

Browse to the address at `develop.vagrant.dev` using `HTTP` or `HTTPS`. This
will work so long as the hosts file has been updated.

## Adding new vhosts

To add new sites, copy the template vhost in either `httpd/vhosts` or
`nginx/vhosts`, name it something else, and paste it in the same directory;
configure the paths in the new file; make sure that path exists in `sites`.
Add another entry to the host OS' `hosts` file. Reload the server. The new
vhost will be available from `newsubvhost.vagrant.dev`.

## Post-provision

Read the `README.md` in `post-provision` to see how post-provision scripts and
DB imports work.

## Debugging PHP

Xdebug is running. It is configured according this tutorial:

https://danemacmillan.com/how-to-configure-xdebug-in-phpstorm-through-vagrant/

The `xdebug.idekey` is `PHPSTORM`, and the `xdebug.remote_port` is `9000`.

---

# Dependencies

This vagrant provision includes the following dotfiles:

https://github.com/danemacmillan/dotfiles

It is installed during post-provision.

---

# Author

[Dane MacMillan](https://danemacmillan.com)

# License

MIT 2015
