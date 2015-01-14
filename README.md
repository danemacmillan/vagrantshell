vagrantshell
============

This is a Vagrant box provisioned using plain old bash shell scripting. Avoid
this box if you are hip, trendy, or both; they will all laugh at you.

## Who is this for?

This setup is for newcomers to Web development. It is also for veterans
looking to add virtualization to their development toolbelt without being
inundanted by a hefty learning curve that involves a tonne of trendy new
technologies and nomenclatures. This is why Bash is the provisioner. It is
familiar; it is easy to understand. Once familiarity takes hold, I encourage
you to start looking at more advanced build processes.

There will come a time when `saltstack` or `ansible` will be used, but that
will also exist in a different repo.

## Technology stack

### Major

- CentOS 6.6
- Nginx 1.6+
- PHP 5.5+ (PHP-FPM & opcache)
- Percona 5.6+ (MySQL)
- Redis
- MongoDB
- Xdebug (read below)

### Minor

- Git 2.2+
- Rsync 3.1+

## Installation

### (For Windows users only)

If you are on Windows and are still using the basic command prompt, stop using
it. It has nothing to offer. Use [cmder](https://bliker.github.io/cmder/).

### Install VirtualBox

If you have OSX, just use `brew`, otherwise have a look here:

https://www.virtualbox.org/wiki/Downloads

### Install Vagrant

If you have OSX, just use `brew`, otherwise have a look here:

https://www.vagrantup.com/downloads.html

### Install guest additions plugin

`vagrant plugin install vagrant-vbguest`

https://github.com/dotless-de/vagrant-vbguest

### Edit hosts file

This is necessary so that the environment can be accessed in a browser. Edit
`/etc/hosts` to include the following line:

`192.168.80.80 dev develop.vagrant.dev`

On Windows, the file is located at `C:\Windows\System32\Drivers\etc\hosts`.

### Cloning `vagrantshell`

- Navigate to the directory you want to work from.

- `git clone git@github.com:danemacmillan/vagrantshell.git` or `git clone https://github.com/danemacmillan/vagrantshell.git` (if you do not have SSH keys).

- `cd` into it.

### Provisioning

1. Copy any post-provision scripts or SQL dumps into `vagrantshell/post-provision`.
These will be files used to build the actual project you want to develop. Without
these, the vagrantshell will just be a hosting environment ready to start new
projects. If there none, this step can be ignored.

2. Run `vagrant up` in the `vagrantshell` directory where the `VagrantFile` file
exists.

3. Wait for everything to install. This can take about ten minutes, depending
on the connection.

## Development

### Log in

From the `vagrantshell` directory that contains the `VagrantFile` file, run
`vagrant ssh`. You are in CentOS as user, `vagrant`. For root access,
type, `sudo su`.

### (For Windows users only)

Oddly, the dotfiles are not sourced during post-provision, so upon SSH'ing into
the box for the first time, run `source ~/.dotfiles/bootsrap.sh`. This will
change the color of your PS1 and add a tonne of handy functionality.


### Directories

A default root directory of `develop.vagrant.dev` will be created in `sites`.
There is a wildcard vhost entry which will serve any content within the `sites`
directory, using the exact directory name created.

By default, the server parses documents from `/vagrant/sites/develop.vagrant.dev`.
Additional sites can be created under `/vagrant/sites` to test different
codebases. On your host machine, point your IDE or editor to
`/your/local/path/vagrantshell/sites/develop.vagrant.dev` to make changes.

### Access from Web browser

Browse to the address at `develop.vagrant.dev` using `HTTP` or `HTTPS`. This
will work so long as the hosts file has been updated.

### Adding new vhosts

Create a new directory in `sites`. Nginx will automatically pick up on it. A
corresponding `/etc/hosts` entry should exist, otherwise the new directory will
be inaccessible. For example, create a directory, `tests.vagrant.dev` or
`foobar.dev` in `sites`, reload `nginx` (`/etc/init.d/nginx reload`), and edit
the host's host file to include `192.168.80.80 foobar.dev`, and browse to it.
Note that the directory name will be *exactly* what should be typed in a browser's
address bar.

The setup is a little different if using the Apache server, as it does not
support wildcard server names like nginx.

### Post-provision

Read the `README.md` in `post-provision` to see how post-provision scripts and
DB imports work.

### Debugging PHP

Xdebug is running. It is configured according this tutorial:

https://danemacmillan.com/how-to-configure-xdebug-in-phpstorm-through-vagrant/

The `xdebug.idekey` is `PHPSTORM`, and the `xdebug.remote_port` is `9000`.

## Dependencies

This vagrant provision includes the following dotfiles:

https://github.com/danemacmillan/dotfiles

It is installed during post-provision.

## Note

This box is Magento-friendly. The proper variables and rewrites are
included for Magento development. This does not mean only Magento can be
developed on this box. The Magento settings do not change any other type of
development.

## Author

[Dane MacMillan](https://danemacmillan.com)

## License

MIT 2015
