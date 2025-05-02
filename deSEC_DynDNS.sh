#!/bin/sh

# This simple bash script to do DynDNS for deSEC.io.
# https://github.com/jameskimmel/deSEC_DynDNS

# Config
# Insert your domain name and the auth token. You can disable IPv4 or IPv6.
DOMAIN_NAME="kaserne.salzmann.solutions"
TOKEN="hNtb6kCBtvtracaC4Rq2qG2fiZin"
ENABLE_IPV4=true
ENABLE_IPV6=true

# You should not need to change anything below this.
UPDATE_NEEDED=false
UPDATE_URL="https://update.dedyn.io/?hostname=$DOMAIN_NAME"

# Check if IPv4 changed
if [ "$ENABLE_IPV4" = true ]; then
IPV4=$(curl -s -4 https://checkipv4.dedyn.io)
  DNS_IPV4=$(dig +short "$DOMAIN_NAME" A | head -n 1)

  if [ "$DNS_IPV4" != "$IPV4" ]; then
    UPDATE_NEEDED=true
  fi
fi

# Check if IPv6 changed
if [ "$ENABLE_IPV6" = true ]; then
  IPV6=$(curl -s -6 https://checkipv6.dedyn.io)
  DNS_IPV6=$(dig +short "$DOMAIN_NAME" AAAA | head -n 1)

  if [ "$DNS_IPV6" != "$IPV6" ]; then
    UPDATE_NEEDED=true
  fi
fi

# If an update is needed, build the update URL and send request
if [ "$UPDATE_NEEDED" = true ]; then

 # Append IPs to update URL if enabled
  if [ "$ENABLE_IPV4" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv4=$IPV4"
  fi

  if [ "$ENABLE_IPV6" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv6=$IPV6"
  fi

  echo "Updating DynDNS with: $UPDATE_URL"
  curl -s "$UPDATE_URL" --header "Authorization: Token $TOKEN"

else 
  echo "No update needed."
  exit 0
fi