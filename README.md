# deSEC_DynDNS

deSEC_DynDNS is a DynDNS for deSEC.io written in bash.  
It only issues an update command when your IP has changed.

How to install it:
```bash
sudo apt install curl
wget https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

On deSEC.io, create your auth token. Make sure that you have already created the A and/or AAAA records, since the auth token is not allowed to do that. 

Edit the domain and the token in the script.
```bash
nano deSEC_DynDNS.sh
```

To test your config, run the script: 
```bash
./deSEC_DynDNS.sh
```

If you want to run it every 5min, creat a cronjob like this:  
```bash
crontab -e
```

Append at the end of the file: 
```bash
*/5 * * * * /home/YourUserName/deSEC_DynDNS.sh > /dev/null
```
**Don't forget the change the path to your home directory.**

Hope this works for you! If you have any suggestions, please let me know by opening up an issue.

Optionally:
If you use local DNS overrides like unbound, add @8.8.8.8 or @1.1.1.1 to your dig command. 
It should look like this:
```bash
  DNS_IPV4=$(dig @1.1.1.1 +short "$DOMAIN_NAME" A | head -n 1)
```

Otherwise your IPs will always differ and the script will always do an needless update.
