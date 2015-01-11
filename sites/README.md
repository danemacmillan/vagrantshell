# Develop

A default root directory of `develop` will be created in here. There is a
vhost entry which will serve any content within.

# Adding new vhosts

To add new sites, copy the template vhost in either `httpd/vhosts` or
`nginx/vhosts` and name it something else; configure the paths in the new file;
make sure that path exists in `sites`. Add another entry to the host OS'
`hosts` file. Reload the server. The new vhost will be available from
`newsubvhost.vagrant.dev`.
