# deSEC_DynDNS

**deSEC_DynDNS** is a simple DynDNS script for [deSEC.io](https://desec.io) that updates your DNS records only when your IP address changes.  

Tested on **Debian 12**, **Ubuntu 24.04.2 LTS**, **macOS 15.4.1**, and **OPNsense 25.1.5 (FreeBSD 14.2)**  

Feel free to contribute support for other environments, improvements, suggestions or correct my spelling mistakes :blush:    

## Update logic
This script tries to detect our IPv4 and IPv6 and set it in the Update URL.  
If the script can't detect an IPv4 or IPv6, it will leave it empty. That way, a possible stale A or AAAA record on deSEC will get deleted, if deSEC also does not detect an IP. Even manually created records on the webGUI will get deleted.  
This could potentially help you even noticing that there is a problem, when for whatever reason your host looses IPv4 or IPv6.  
If you don't like that behavior, you can use the preserve option.  
That way, it will leave the IPv4 or IPv6 untouched and the script will not check for IP changes for that protocol.  

If you only want an A record but no AAAA record or vice versa, you should make use of the preserve option.  

If you have a static IPv4 or IPv6 prefix, you can also make use of the preserve option to not waste resources.  

## Prepare Ubuntu/Debian:
```bash
sudo apt install curl
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

## Prepare on macOS:
```bash
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

## Prepare on OPNsense:  
Install os-bind in the webGUI under System -> Firmware -> Plugins
After that, access the shell over ssh and enter:
```sh
curl -o deSEC_DynDNS.sh https://raw.githubusercontent.com/jameskimmel/deSEC_DynDNS/refs/heads/main/deSEC_DynDNS.sh
chmod +x deSEC_DynDNS.sh
```

## Configure 
On [deSEC.io](https://desec.io), create your auth token.  

Edit the domain and the token in the script with an editor you like. I use nano as an example.  
```bash
nano deSEC_DynDNS.sh
```
### Command paths
For Debian and Ubuntu the paths should already be correct.
For OPNsense and macOS, you have to adjust them. 

### Preserve option
This will set the update URL for that IP to preserve, thus not create, modify or delete records for that IP protocol.  
It will also disable checks for that protocol, since they are no longer needed in that case.  

## Test your config
To test your config, run the script:  
```bash
./deSEC_DynDNS.sh
```

## run it automatically
Depending on your OS, there are different ways to repeatedly run your script.  
In these examples, we use a 5min intervall.  

### Linux
Create a cronjob:  
```bash
crontab -e
```

Append at the end of the file: 
```bash
*/5 * * * * /home/YourUserName/deSEC_DynDNS.sh > /dev/null
```
**Don't forget the change the path to your home directory.**  

### OPNsense
SSH into your OPNsense shell.  
OPNsense does not have nano installed, so we use vi instead to edit files.  
```bash
vi /usr/local/opnsense/service/conf/actions.d/actions_desecdyndns.conf
```
press "i" to insert:
```bash
[run]
command:/root/deSEC_DynDNS.sh
parameters:
type:script
message:run deSEC DynDNS
description:deSEC DynDNS Update
```
save and exit by pressing esc -> : -> wq -> enter

restart configd (or even better, reboot OPNsense)
```bash
service configd restart
```

To test your config, run the script:  
```bash
./deSEC_DynDNS.sh
```

If your script works, you can no leave the shell and go into the webGUI.  
Go to System -> Settings -> Cron  
Click to add a new job.  
Change minutes to -> */5 and hours to -> *  
Under commands you should see deSEC DynDNS Update (the description text of our configd action).  
Under description add something like "deSEC DynDNS Update".  
Click save and you are done.  

### macOS
I think it should be done with launchd ~/Library/LaunchAgents, but I haven't had the time to look into it. Happy to implement your pull request. 
