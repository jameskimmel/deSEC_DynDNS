# deSEC_DynDNS

deSEC_DynDNS is a DynDNS for DeSEC.io written in bash.  
It only issues an update command when your IP has changed.



How to install it:
```bash
sudo apt install curl
wget https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
sudo chmod +x deSEC_DynDNS.sh
```

On deSEC.io, create your auth token. Make sure that you have already created the A and/or AAAA records, since the auth token is not allowed to do that. 

Edit the domain and the token in the script.
```bash
nano deSEC_DynDNS.sh
```

run the script: 
```bash
./deSEC_DynDNS.sh
```

to set it as a cronjob every 5 minutes:
```bash
crontab -e
```

Append at the end of the file: 

```bash
*/5 * * * *  sleep $(( RANDOM % 300 )); /home/YourUserName/deSEC_DynDNS.sh > /dev/null
```
The sleep function will randomly delay the update up to 5min, to not overwhelm deSEC servers.  
**Don't forget the change the path to your home directory.**

Optionally:
If you use local DNS overrides like unbound, add @8.8.8.8 or @1.1.1.1 after the dig command. Otherwise your IPs will always differ and the script will always do an update.
