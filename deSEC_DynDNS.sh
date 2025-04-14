#!/bin/bash

# This simple bash script to do DynDNS for deSEC.io.
# https://github.com/jameskimmel/deSEC_DynDNS

# Config
# Insert your domain name and the auth token. You can disable IPv4 or IPv6.
DOMAIN_NAME="yourdomain.com"
TOKEN="1234"
ENABLE_IPV4=true
ENABLE_IPV6=true

# You should not need to change anything below this.
CACHEFILE_IPV4="/usr/local/sbin/cache_IPv4.txt"
CACHEFILE_IPV6="/usr/local/sbin/cache_IPv6.txt"
CACHED_IPV4="$(tail -1 "$CACHEFILE_IPV4")"
CACHED_IPV6="$(tail -1 "$CACHEFILE_IPV6")"
UPDATE_NEEDED=false
UPDATE_URL="https://update.dedyn.io/?hostname="

# Check if IPv4 changed
if $ENABLE_IPV4; then
IPV4="$(curl -s -4 https://checkipv4.dedyn.io)"
	if [ "$CACHED_IPV4" != "$IPV4" ]; then
		UPDATE_NEEDED=true
	fi
fi

# Check if IPv6 changed
if $ENABLE_IPV6; then
IPV6="$(curl -s -6 https://checkipv6.dedyn.io)"
        if [ "$CACHED_IPV6" != "$IPV6" ]; then
            UPDATE_NEEDED=true
        fi
fi

# if and update is needed, create the update URL
if $UPDATE_NEEDED; then

# combining the URL with your domain name
UPDATE_URL+="$DOMAIN_NAME"

# IPv4
if $ENABLE_IPV4; then
UPDATE_URL+="&myipv4="
UPDATE_URL+="$IPV4"
echo "$IPV4" >> "$CACHEFILE_IPV4"
fi

# IPv6
if $ENABLE_IPV6; then
UPDATE_URL+="&myipv6="
UPDATE_URL+="$IPV6"
echo "$IPV6" >> "$CACHEFILE_IPV6""
fi

# do the actual update
echo "$UPDATE_URL"
curl "$UPDATE_URL" --header "Authorization: Token $TOKEN"

else 
exit
fi