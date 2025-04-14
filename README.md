# deSEC_DynDNS

deSEC_DynDNS is a DynDNS for DeSEC.io written in bash.  
It caches the last set IP and only issues an update command, when the IP changed.

How to use it:
```bash
sudo apt install curl
cd /usr/local/sbin/
sudo wget https://github.com/jameskimmel/deSEC_DynDNS/blob/main/deSEC_DynDNS.sh
sudo chmod +x deSEC_DynDNS.sh
```

run it 
```bash
sudo ./deSEC_DynDNS.sh
```

To set it as a cronjob every 5 minutes:
```bash
sudo crontab -e
```
Append at the end of the file:
```bash
sudo */5 * * * *  /usr/local/sbin/deSEC_DynDNS.sh > /dev/null
```
