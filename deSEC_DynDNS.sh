#!/bin/sh

# Simple DynDNS script for deSEC.io.
# https://github.com/jameskimmel/deSEC_DynDNS

# Config:
# Insert your domain name and the auth token. 
DOMAIN_NAME="yourdomain.com"
TOKEN="1234"

# Preserve:
# This will set the update URL to preserve, 
# therefore not touching your current record.
PRESERVE_IPV4=false
PRESERVE_IPV6=false

# Paths:
# For Debian and Ubuntu, paths should already be correct.
# Use the command "which", to find out where these commands are located on your OS.
# For OPNsense, paths are most likely /usr/local/bin/ instead
# For macOS, sleep is located at /bin/sleep

DIG_CMD='/usr/bin/dig'
CURL_CMD='/usr/bin/curl'
OD_CMD='/usr/bin/od'
AWK_CMD='/usr/bin/awk'
SLEEP_CMD='/usr/bin/sleep'
HEAD_CMD='/usr/bin/head'

# You should not need to change anything below this line!

# Nameserver used for dig
NAMESERVER1='ns1.desec.io'

# Disable IPv4 or IPv6
CHECK_IPV4=true
CHECK_IPV6=true

# Start
UPDATE_NEEDED=false
UPDATE_URL="https://update.dedyn.io/?hostname=$DOMAIN_NAME"

# To not overwhelm deSEC servers all at the same time  
# we add a random delay. By using a delay between 10 and 290 seconds, we have at least a 10 second delay to the 5m mark.  
MIN_DELAY=10
MAX_DELAY=290
RAND_NUM=$($OD_CMD -An -N2 -t u /dev/urandom | $AWK_CMD '{print $1}')
RANDOM_DELAY=$((MIN_DELAY + RAND_NUM % (MAX_DELAY - MIN_DELAY + 1)))
$SLEEP_CMD $RANDOM_DELAY

# Preserve logic:
# If we have a preserver option set to true, we don't want to check for updates for that IP.
# We disable the "check" variable, but we still want to include it in the update URL.

# Copy user settings
SET_IPV4=$CHECK_IPV4
SET_PV6=$CHECK_IPV6

# Check if the preserve option is enabled. 
# If yes, disable the check and set the IP to preserve  
if [ "$PRESERVE_IPV4" = true ]; then
  CHECK_IPV4=false
  IPV4="preserve"
fi

if [ "$PRESERVE_IPV6" = true ]; then
  CHECK_IPV6=false
  IPV6="preserve"
fi

# Check if IPv4 changed
if [ "$CHECK_IPV4" = true ]; then
IPV4=$($CURL_CMD -s -4 https://checkipv4.dedyn.io)
  DNS_IPV4=$($DIG_CMD  @$NAMESERVER1 +short "$DOMAIN_NAME" -t A | $HEAD_CMD  -n 1)

  if [ "$DNS_IPV4" != "$IPV4" ]; then
    UPDATE_NEEDED=true
  fi
fi

# Check if IPv6 changed
if [ "$CHECK_IPV6" = true ]; then
  IPV6=$($CURL_CMD -s -6 https://checkipv6.dedyn.io)
  DNS_IPV6=$($DIG_CMD  @$NAMESERVER1 +short "$DOMAIN_NAME" -t AAAA | $HEAD_CMD  -n 1)

  if [ "$DNS_IPV6" != "$IPV6" ]; then
    UPDATE_NEEDED=true
  fi
fi

# If an update is needed, build the update URL and send a request
if [ "$UPDATE_NEEDED" = true ]; then

 # Append IPs to update URL if enabled
  if [ "$SET_IPV4" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv4=$IPV4"
  fi

  if [ "$SET_IPV6" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv6=$IPV6"
  fi

  echo "try to update using this URL: $UPDATE_URL"
  $CURL_CMD -s "$UPDATE_URL" --header "Authorization: Token $TOKEN"
  echo "update should be done. Exiting script"
  exit 0

else 
  echo "No update needed."
  exit 0
fi
