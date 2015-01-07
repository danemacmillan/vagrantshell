# Post provision

## How to run additional scripts

Include any number of files in this directory with the `sh` extension. They
will be sourced in order. For example, include a file called `env.sh` and it
will be sourced after the vagrant provision has completed.

## How to import DB files automatically

Include any number of files in this directory with the `sql` extension. They
will import into the DB automatically during provisioning. For example, include
a file called `latest.sql` and it will be imported. They will be imported in
alphabetical order.

# Uses

This is useful to include deployment scripts to get your actual codebase pulled
into the vagrant build automatically.
