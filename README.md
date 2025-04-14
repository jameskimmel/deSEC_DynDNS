# deSEC_DynDNS

deSEC_DynDNS is a DynDNS for DeSEC.io written in bash.
It caches the last set IP and only issues an update command, when the IP changed.

How to use it:

sudo apt install curl
cd  /usr/local/sbin/
wget /
sudo chmod +x deSEC_DynDNS.sh


run it 
sudo ./deSEC_DynDNS.sh

To set it as a cronjob every 5 minutes:

sudo crontab -e
Append at the end of the file:

sudo */5 * * * *  /usr/local/sbin/deSEC_DynDNS.sh > /dev/null