#!/bin/bash

CONFIG_PATH="/etc/nginx/cf_ips_only.conf"

RULES=$(curl -ks "https://www.cloudflare.com/ips-v{4,6}" -w "\n" |sed "s/^/allow /g" |sed "s/\$/;/g" && printf "\ndeny all;")

LINES=$( wc -l <<< $RULES )

if [[ $LINES -gt 8 ]]; then
    echo "$RULES" > $PATH
else
    # send a warn to admin, but dont change the config
    echo "$(date)| Cant load cf ip list" >>/var/log/cf_update.log
fi
