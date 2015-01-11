# About wildcard vhosts in NGINX

`vagrantshell` makes use of wildcard domains for `nginx`. This means that in
order to start accessing a new project by domain name, simply create a
directory in `sites` with the corresponding domain name, and `nginx` will
automatically start serving it after a reload/restart. For example, create a
new directory called `foobar.dev` in `sites`, add a hosts entry for that
exact domain name `192.168.80.80 foobar.dev`, reload `nginx`, then point the
browser at that domain and all the content within that directory will be
served automatically, without need for additional configuration.

# Custom vhosts

If the default wildcard vhost configuration is not sufficient, you can still
create a new *.conf file in `nginx/vhosts/*.conf` with whatever specific
values required, and then add the corresponding directory in `sites`. This will
not have any impact on the way wildcard domains work. Odds are, this will
not need to be used, except for rare requirements.
