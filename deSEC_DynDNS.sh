#!/bin/sh

# Simple DynDNS script for deSEC.io.
# https://github.com/jameskimmel/deSEC_DynDNS

# Config:
# Insert your domain name and the auth token.
DOMAIN_NAME="yourdomain.com"
TOKEN="1234"

# Preserve:
# This will set the update URL to preserve, therefore not touching your current record.
PRESERVE_IPV4=false
PRESERVE_IPV6=false

# Paths:
# For Debian and Ubuntu, paths should already be correct.
# Use the command "which", to find out where these commands are located on your OS.
# For OPNsense, dig and curl should be located at /usr/local/bin/ and sleep should be located at /bin/sleep
# For macOS, sleep should be located at /bin/sleep
DIG_CMD='/usr/bin/dig'
CURL_CMD='/usr/bin/curl'
OD_CMD='/usr/bin/od'
AWK_CMD='/usr/bin/awk'
SLEEP_CMD='/usr/bin/sleep'
HEAD_CMD='/usr/bin/head'

# You should not need to change anything below this line!

# Nameserver used for dig
NAMESERVER1="ns1.desec.io"

# Set url to determine your own IP
CHECK_IPV4_URL="https://checkipv4.dedyn.io"
CHECK_IPV6_URL="https://checkipv6.dedyn.io"

# Disable IPv4 or IPv6
CHECK_IPV4=true
CHECK_IPV6=true

# Start
UPDATE_NEEDED=false
UPDATE_URL="https://update.dedyn.io/?hostname=$DOMAIN_NAME"

# To not overwhelm deSEC servers all at the same time  
# we add a random delay. By using a delay between 10 and 290 seconds, we have at least a 10-second delay to the 5m mark.  
MIN_DELAY=10
MAX_DELAY=290
RAND_NUM=$($OD_CMD -An -N2 -t u /dev/urandom | $AWK_CMD '{print $1}')
RANDOM_DELAY=$((MIN_DELAY + RAND_NUM % (MAX_DELAY - MIN_DELAY + 1)))
$SLEEP_CMD "$RANDOM_DELAY"

# Preserve logic:
# If we have a preserve option set to true, we don't want to check for updates for that IP.
# We disable the "check" variable, but we still want to include it in the update URL.

# Copy user settings
SET_IPV4="$CHECK_IPV4"
SET_IPV6="$CHECK_IPV6"

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
  IPV4=$($CURL_CMD -4 --connect-timeout 10 --max-time 10 "$CHECK_IPV4_URL")
  CURL_EXIT=$?

  if [ "$CURL_EXIT" -ne 0 ]; then
    echo "Failed to get your IPv4 from $CHECK_IPV4_URL. Curl error: $CURL_EXIT" >&2
    exit 1
  fi

  DNS_IPV4=$($DIG_CMD @$NAMESERVER1 +short "$DOMAIN_NAME" -t A | $HEAD_CMD -n 1)
  DIG_EXIT=$?

  if [ "$DIG_EXIT" -ne 0 ]; then
    echo "Failed to retrieve an A record from $NAMESERVER1. Dig error: $DIG_EXIT" >&2
    exit 1
  fi

  if [ "$DNS_IPV4" != "$IPV4" ]; then
    UPDATE_NEEDED=true
  fi
fi

# Check if IPv6 changed
if [ "$CHECK_IPV6" = true ]; then
  IPV6=$($CURL_CMD -6 --connect-timeout 10 --max-time 10 "$CHECK_IPV6_URL")
  CURL_EXIT=$?

  if [ "$CURL_EXIT" -ne 0 ]; then
    echo "Failed to get your IPv6 from $CHECK_IPV6_URL. Curl error: $CURL_EXIT" >&2
    exit 1
  fi

  DNS_IPV6=$($DIG_CMD @$NAMESERVER1 +short "$DOMAIN_NAME" -t AAAA | $HEAD_CMD -n 1)
  DIG_EXIT=$?

  if [ "$DIG_EXIT" -ne 0 ]; then
    echo "Failed to retrieve an AAAA record from $NAMESERVER1. Dig error: $DIG_EXIT" >&2
    exit 1
  fi

  if [ "$DNS_IPV6" != "$IPV6" ]; then
    UPDATE_NEEDED=true
  fi   
fi

# If an update is needed, build the update URL
if [ "$UPDATE_NEEDED" = true ]; then
  # Append IPs to update URL if enabled
  if [ "$SET_IPV4" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv4=$IPV4"
  fi

  if [ "$SET_IPV6" = true ]; then
    UPDATE_URL="${UPDATE_URL}&myipv6=$IPV6"
  fi

  # Do the actual update 
  UPDATE_RESPONSE=$($CURL_CMD --connect-timeout 10 --max-time 10 -w "%{http_code}" -o /dev/null --header "Authorization: Token $TOKEN" "$UPDATE_URL")
  CURL_EXIT=$?
  
  if [ "$CURL_EXIT" -ne 0 ]; then
    echo "Error: unable to set record(s). Used curl with $UPDATE_URL but failed. Curl error $CURL_EXIT" >&2
    exit 1
  fi

  # Check if the response of our update request is 200
  if [ "$UPDATE_RESPONSE" -eq 200 ]; then
    echo "Success! Successfully updated your record(s) by using this URL: $UPDATE_URL"
    exit 0
  else
    echo "We tried it with this URL $UPDATE_URL. Instead of getting 200 as response, we got this error: $UPDATE_RESPONSE"
    exit 1
  fi
else
  echo "No update needed."
  exit 0
fi
