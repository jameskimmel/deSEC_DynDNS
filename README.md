# deSEC_DynDNS

deSEC_DynDNS is a DynDNS script for deSEC.io.  
It only issues an update command when your IP has changed.

This script depends on curl and dig. 

This script was tested to work on Debian 12, Ubuntu 24.04.2 LTS, and macOS 15.4.1 and OPNsense 25.1.5 (FreeBSD 14.2)  
Please, feel free to contribute your own environment.

Installation on Ubuntu/Debian:
```bash
sudo apt install curl
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

Installation on macOS:
```bash
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

Installation on OPNsense (crontab is currently work in progress):  
Access the shell over ssh.
```sh
pkg install bind-tools
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

On deSEC.io, create your auth token. Make sure that you have already created the A and/or AAAA records, since the auth token is by default not allowed to do that. 

Edit the domain and the token in the script with an editor you like. I use nano as an example.  
```bash
nano deSEC_DynDNS.sh
```

To test your config, run the script: 
```bash
./deSEC_DynDNS.sh
```

If you want to run it every 5min, create a cronjob:  
```bash
crontab -e
```

Append at the end of the file: 
```bash
*/5 * * * * /home/YourUserName/deSEC_DynDNS.sh > /dev/null
```
**Don't forget the change the path to your home directory.**

Hope this works for you! If you have any suggestions, please let me know by opening up an issue.

**If you use DNS overrides:**  
If you use local DNS overrides like unbound or hosts file, you really should specifiy the DNS server for dig.  
Otherwise your IPs will always differ and the script will always do an needless update.  
Here is an example of dig using Cloudflare DNS server 1.1.1.1:  
```bash
  DNS_IPV4=$(dig @1.1.1.1 +short "$DOMAIN_NAME" A | head -n 1)
```

