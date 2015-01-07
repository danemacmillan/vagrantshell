# Post provision scripts

Include any number of files in this directory with the `sh` extension. They
will be sourced in order. For example, include a file called `env.sh` and it
will be sourced after the vagrant provision has completed.

## Uses

This is useful to include deployment scripts to get your actual codebase pulled
into the vagrant build automatically.
