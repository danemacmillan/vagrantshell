# About these certs

## `_.vagrant.dev.*`

These are for wildcard subdomains. That means any subdomain will work with SSL.
For example, `example.vagrant.dev` or `foobar.vagrant.dev`. The `vagrant.dev`
domain must be present.

## `_.dev`

These are also for wildcard domains, but shortened. This means you can
`example.dev` or `foobar.dev`.

# Generating new certs

If the above certs are not enough for testing purposes, new certs can always be
generated. Be sure to create the custom vhost configurations as well.

```
cd /vagrant/ssl
openssl genrsa 2048 > newdomain.dev.key
openssl req -new -x509 -nodes -sha1 -days 3650 -key newdomain.dev.key > newdomain.dev.crt
```

The third command will ask for a "Common Name (e.g. server FQDN or YOUR name)"
domain name to use. If it is `newdomain.dev` enter that. If you want wildcards
on `newdomain.dev` enter `*.newdomain.dev`.

```
openssl x509 -noout -fingerprint -text < newdomain.dev.crt > newdomain.dev.info
cat newdomain.dev.crt newdomain.dev.key > newdomain.dev.pem
```
