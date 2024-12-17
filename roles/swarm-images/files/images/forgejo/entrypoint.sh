#!/bin/sh
set -e # fail on error

# This helper allows to run stuff as the forgejo user
# TODO: looks like it's missing the `sudo` executable
forgejo_cli() { sudo -u git forgejo --config /data/gitea/conf/app.ini "$@"; }

# TODO wait until database is alive
#  - port alive                         (bad)
#  - a mock query like 'SELECT 1' works (better)

# DB migration
forgejo_cli migrate

# TODO create admin user (if it does not exists already)
# use `forgejo admin user list` and `forgejo admin user create`

# TODO make forgejo trust our TLS certificate
#   Apparently /usr/local/share/ca-certificates is involved

# TODO wait until authentication server is alive
#  - port alive                         (bad)
#  - check that the homepage responds   (better)

# TODO setup authentication (if it does not exist)
# use `forgejo admin auth list` and `forgejo admin auth add-oauth`
#   --auto-discover-url is `https://auth.vcc.internal/.well-known/openid-configuration`
#   --provider is openidConnect

# Execute the original entrypoint
exec /bin/s6-svscan /etc/s6 "$@"
