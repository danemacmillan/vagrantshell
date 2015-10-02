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

Read the `changelog` below for more information.

### Major

- CentOS 6.7
- Nginx 1.9+ (mainline branch)
- PHP 5.5+ (PHP-FPM & opcache)
- Percona 5.6+ (MySQL)
- Redis
- MongoDB
- Varnish 3.0+
- Node.js

### Minor

- Xdebug (read below)
- Git 2.5+
- Rsync 3.1+

### Additional

- The `SPDY` / `HTTP2` protocol is activated for Nginx when using `HTTPS`.

## The `vshell` utility

`vagrantshell` includes a `vshell` Bash utility for managing certain tasks
related to the box. It is located in `/vagrant/bin`. It is recommended to add
it to the box's path: `export PATH="/vagrant/bin:$PATH"`

```
vshell 2.0.0
'vshell' is used for managing the vagrantshell VM.

Usage:
 vshell [ Options ]

Options:
 help                Show this usage message.
 map                 Map contents of /vagrant/etc/ into core /etc/.
 restart             Restart multiple daemons.
 update              Update vagrantshell from master.
 xdebug              Toggle PHP Xdebug on or off.

Examples:
 Remap new /vagrant/etc/ files into core /etc/:
   vshell map
```

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

`192.168.80.80 dev vagrant.dev develop.vagrant.dev`

On Windows, the file is located at `C:\Windows\System32\Drivers\etc\hosts`.

### Cloning `vagrantshell`

- Navigate to the directory you want to work from.

- `git clone git@github.com:danemacmillan/vagrantshell.git` or `git clone https://github.com/danemacmillan/vagrantshell.git` (if you do not have SSH keys).

- `cd` into it.

### Provisioning

1. Copy any post-provision scripts or SQL dumps into `vagrantshell/post-provision`.
These will be files used to build the actual project you want to develop. Without
these, the vagrantshell will just be a hosting environment ready to start new
projects. If there are none, this step can be ignored.

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
will work so long as the hosts file has been updated. Note that the `SPDY` \ 
`HTTP2` protocol will be used.

### Adding new virtual hosts

Create a new directory in `sites`. Nginx will automatically pick up on it. A
corresponding `/etc/hosts` entry should exist, otherwise the new directory will
be inaccessible. For example, create a directory, `tests.vagrant.dev` or
`foobar.dev` in `sites`, reload `nginx` (`/etc/init.d/nginx reload`), and edit
the host's host file to include `192.168.80.80 foobar.dev`, and browse to it.
Note that the directory name will be *exactly* what should be typed in a browser's
address bar.

### Post-provision

Read the `README.md` in `post-provision` to see how post-provision scripts and
DB imports work.

### Debugging PHP

Xdebug is not enabled by default. It is configured according this tutorial:

https://danemacmillan.com/how-to-configure-xdebug-in-phpstorm-through-vagrant/

The `xdebug.idekey` is `PHPSTORM`, and the `xdebug.remote_port` is `9000`.

## Dependencies

This vagrant provision includes the following dotfiles:

https://github.com/danemacmillan/dotfiles

It is installed during post-provision.

## Framework / CMS notes

There is no reason why any framework or CMS would not work with this Vagrant
box. Unless very custom server configurations are required, the defaults are
plenty. However, this Vagrant box has been configured to easily allow such
customizations.

### Magento

This box is [Magento](http://www.magentocommerce.com/download)-friendly. The
proper variables and rewrites are included for Magento development. This does
not mean only Magento can be developed on this box. The Magento settings do not
change any other type of development. Magento version 1.9+ has been tested.
Downgrading the version of PHP to 5.4 or 5.3 will increase compatibility for
older releases of Magento.

### Ghost (Node.js)

Port `2368` from the guest is forwarded to port `2368` on the host. Instructions
to install and run an instance of the [Ghost](https://github.com/tryghost/Ghost)
blogging platform are available online.

### Wordpress

[Wordpress](https://wordpress.org/) development is not an issue.

## Troubleshooting

- Running `vagrant halt` and then `vagrant up` will cause the SELinux enforce
policy to reactivate. This blocks Nginx from being accessible. Since CentOS 6.6
[the SELinux policy for Nginx has been changed](nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/).
 For the meantime, after Vagrant has been booted, SSH into the box and run
 `setenforce 0` as root. Restart Nginx `/etc/init.d/nginx restart` and PHP-FPM
 `/etc/init.d/php-fpm restart`. The server will devliver content once again.

## Author

[Dane MacMillan](https://danemacmillan.com)

## Changelog

### 2.0.0 (October 2, 2015)

The entire structure of the repository was changed. If a fork from before this
date exists, it will no longer be compatible with this version.

## Copyright & license

The MIT License (MIT)

Copyright (C) 2015 vagrantshell - Released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
