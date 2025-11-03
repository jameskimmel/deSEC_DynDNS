#!/bin/sh

# Simple DynDNS script for deSEC.io.
# Version 1.1
# https://github.com/jameskimmel/deSEC_DynDNS

# Config:
# Insert your domain name and the auth token.
DOMAIN_NAME='InsertYourDomainHere'
TOKEN='InsertYourTokenHere'

# Paths:
# For Debian and Ubuntu, paths should already be correct.
# Use the command "which", to find out where these commands are located on your OS.
# For OPNsense, dig and curl should be located at /usr/local/bin/ and sleep should be located at /bin/sleep
# For macOS, sleep should be located at /bin/sleep
DIG_CMD='/usr/bin/dig'
CURL_CMD='/usr/bin/curl'
SLEEP_CMD='/usr/bin/sleep'
AWK_CMD='/usr/bin/awk'
HEAD_CMD='/usr/bin/head'
OD_CMD='/usr/bin/od'

# Preserve:
# This will set the update URL to preserve, therefore not touching your current record.
# Please insert 'YES' or 'NO'
PRESERVE_IPV4='NO'
PRESERVE_IPV6='NO'

# Nameservers for dig to check your A and AAAA record. If for some reason the deSEC DNS server isn't working, we use
# Cloudflare as backup DNS server.
NAMESERVER='ns1.desec.io'
NAMESERVER_BACKUP='1.1.1.1'

# Set URLs to determine your own IP
# My backup servers don't do access log, but from an uptime perspective, you are probably better off using
# other providers like https://api4.ipify.org and https://api6.ipify.org instead.
CHECK_IPV4_URL='https://checkipv4.dedyn.io'
CHECK_IPV6_URL='https://checkipv6.dedyn.io'
CHECK_IPV4_URL_BACKUP='https://checkipv4.salzmann.solutions'
CHECK_IPV6_URL_BACKUP='https://checkipv6.salzmann.solutions'

###############################################################
### You should not need to change anything below this line! ###
###############################################################

# Variables
UPDATE_URL="https://update.dedyn.io/?hostname=$DOMAIN_NAME"
UPDATE_NEEDED='NO'
IPV4_UNDETECTABLE='NO'
IPV6_UNDETECTABLE='NO'

# To not overwhelm deSEC servers all at the same time
# we add a random delay. By using a delay between 10 and 290 seconds, we have at least a 10-second delay to the 5m mark.
MIN_DELAY=10
MAX_DELAY=290
RAND_NUM=$($OD_CMD -An -N2 -t u /dev/urandom | $AWK_CMD '{print $1}')
RANDOM_DELAY=$((MIN_DELAY + RAND_NUM % (MAX_DELAY - MIN_DELAY + 1)))
$SLEEP_CMD $RANDOM_DELAY

# It the preserve option is enabled, we set the IP to 'preserve'
if [ "$PRESERVE_IPV4" != 'NO' ]; then
  IPV4='preserve'
fi

if [ "$PRESERVE_IPV6" != 'NO' ]; then
  IPV6='preserve'
fi

# Check IPv4 (only if preserve is not set)
if [ "$PRESERVE_IPV4" = 'NO' ]; then
  IPV4=$($CURL_CMD -4 --connect-timeout 10 --max-time 10 --silent "$CHECK_IPV4_URL")
  CURL_EXIT=$?

  # If curl returned an error, we try the backup nameserver
  if [ $CURL_EXIT -ne 0 ]; then
    echo "Failed to get your IPv4 from $CHECK_IPV4_URL. Curl error: $CURL_EXIT. We try the backup URL." >&2
    IPV4=$($CURL_CMD -4 --connect-timeout 10 --max-time 10 --silent "$CHECK_IPV4_URL_BACKUP")
    CURL_EXIT=$?

    # If curl again returned an error, we set IPv4 to undetected
    if [ $CURL_EXIT -ne 0 ]; then
      echo "also failed to get your IPv4 from $CHECK_IPV4_URL_BACKUP. Curl error: $CURL_EXIT" >&2
      IPV4_UNDETECTABLE='YES'
    fi

  fi

  # Get the A record
  DNS_IPV4=$($DIG_CMD @$NAMESERVER +short "$DOMAIN_NAME" -t A | $HEAD_CMD -n 1)
  DIG_EXIT=$?

  # If we can't connect to the DNS server, we use the backup one
  if [ $DIG_EXIT -ne 0 ]; then
    echo "Failed to get a response from $NAMESERVER. Dig error: $DIG_EXIT. We try the backup DNS" >&2
    DNS_IPV4=$($DIG_CMD @$NAMESERVER_BACKUP +short "$DOMAIN_NAME" -t A | $HEAD_CMD -n 1)
    DIG_EXIT=$?

    # If we also can't connect to the second DNS, we have a serious issue and exit the programm
    if [ $DIG_EXIT -ne 0 ]; then
      echo "Also failed to get a response from $NAMESERVER_BACKUP. Dig error: $DIG_EXIT. Script will now exit." >&2
      exit 1
    fi

  fi

  # If the A record isn't what IPv4 we detected or if we found a record but could not determine
  # our IP, we need an update.
  if [ "$DNS_IPV4" != "$IPV4" ] || [ "$IPV4_UNDETECTABLE" = 'YES' ]; then
    UPDATE_NEEDED='YES'
  fi

fi

# Check IPv6 (only if preserve is not set)
if [ "$PRESERVE_IPV6" = 'NO' ]; then
  IPV6=$($CURL_CMD -6 --connect-timeout 10 --max-time 10 --silent "$CHECK_IPV6_URL")
  CURL_EXIT=$?

  # If curl returned an error, we try the backup nameserver
  if [ $CURL_EXIT -ne 0 ]; then
    echo "Failed to get your IPv6 from $CHECK_IPV6_URL. Curl error: $CURL_EXIT. We try the backup URL." >&2
    IPV6=$($CURL_CMD -6 --connect-timeout 10 --max-time 10 --silent "$CHECK_IPV6_URL_BACKUP")
    CURL_EXIT=$?

    # If curl again returned an error, we set IPv6 to undetected
    if [ $CURL_EXIT -ne 0 ]; then
      echo "also failed to get your IPv6 from $CHECK_IPV6_URL_BACKUP. Curl error: $CURL_EXIT" >&2
      IPV6_UNDETECTABLE='YES'
    fi

  fi

  # Get the AAAA record
  DNS_IPV6=$($DIG_CMD @$NAMESERVER +short "$DOMAIN_NAME" -t AAAA | $HEAD_CMD -n 1)
  DIG_EXIT=$?

  # If we can't connect to the DNS server, we use the backup one
  if [ $DIG_EXIT -ne 0 ]; then
    echo "Failed to get a response from $NAMESERVER. Dig error: $DIG_EXIT. We try the backup DNS" >&2
    DNS_IPV6=$($DIG_CMD @$NAMESERVER_BACKUP +short "$DOMAIN_NAME" -t AAAA | $HEAD_CMD -n 1)
    DIG_EXIT=$?

    # If we also can't connect to the second DNS, we have a serious issue and exit the programm
    if [ $DIG_EXIT -ne 0 ]; then
      echo "Also failed to get a response from $NAMESERVER_BACKUP. Dig error: $DIG_EXIT. Script will now exit." >&2
      exit 1
    fi

  fi

  # If the AAAA record isn't what IPv6 we detected or if we found a record but could not establish
  # our IP, we need an update.
  if [ "$DNS_IPV6" != "$IPV6" ] || [ "$IPV6_UNDETECTABLE" = 'YES' ]; then
    UPDATE_NEEDED='YES'
  fi

fi

# If an update is needed, build the update URL
if [ "$UPDATE_NEEDED" = 'YES' ]; then

  # When the IPv4 or IPv6 was detectable, we set it into the update url.
  # If not, we will leave it empty.
  # That way, the deSEC update server decides based on what it detects.

  if [ "$IPV4_UNDETECTABLE" = 'NO' ]; then
    UPDATE_URL="${UPDATE_URL}&myipv4=$IPV4"
  fi

  if [ "$IPV6_UNDETECTABLE" = 'NO' ]; then
    UPDATE_URL="${UPDATE_URL}&myipv6=$IPV6"
  fi

  # Do the actual update
  UPDATE_RESPONSE=$($CURL_CMD --connect-timeout 10 --max-time 10 --silent --header "Authorization: Token $TOKEN" "$UPDATE_URL")
  CURL_EXIT=$?

    if [ $CURL_EXIT -ne 0 ]; then
    echo "Error! Used curl with $UPDATE_URL as update URL, but failed. Curl error $CURL_EXIT" >&2
    exit 1
  fi

  # Check if the update worked and we got 'good' as answer
  if [ "$UPDATE_RESPONSE" = 'good' ]; then
    echo "Success! Successfully updated your record(s) by using this URL: $UPDATE_URL"
    exit 0
  else
    echo "Error! Used this URL $UPDATE_URL, but instead of getting 'good' as response, we got this: $UPDATE_RESPONSE"
    exit 1
  fi

else
  echo 'No update needed.'
  exit 0
fi
