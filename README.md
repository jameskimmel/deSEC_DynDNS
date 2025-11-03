# deSEC_DynDNS

**deSEC_DynDNS** is a simple DynDNS script for [deSEC.io](https://desec.io) that updates your DNS records only when your IP address changes.  

Tested on **Debian 12**, **Ubuntu 24.04.2 LTS**, **macOS 15.4.1**, and **OPNsense 25.1.5 (FreeBSD 14.2)**  

Feel free to contribute support for other environments, improvements, suggestions or correct my spelling mistakes :blush:    

## Update logic
If you issue an update request to the deSEC update url, deSEC will try to detect what IPs you have and set them accordingly.    

This script behaves differently. It first detects your IPs and checks if they are different from the current records.  
If that is the case, it will not simply issue the update URL and let deSEC guess what IPs you have, instead it will issue the update URL with the detected IPs coded in.  

If the script can't detect an IP, it will leave it empty. If it is empty and the deSEC update url also can't detect an IP, it will get deleted. This will even be the case for records you created manually in the webGUI. That way stale records will get deleted. This might even help you noticing that there is a problem, when for whatever reason your host lost its IPv4 or IPv6.  

If you don't like that behavior for some reasons, you can set PRESERVE_IPV4 or PRESERVE_IPV6 to "YES".  
This will add the preserve option in the update URL and leave manually created records in the webGUI or stale records untouched. Because of that, it will also completly disable any checks for that procotol.

If you want to disable IPv4 or IPv6, you can set DISABLE_IPV4 or DISABLE_IPV4 to "YES". The only thing this will do, is setting the preserve option to "YES", so it is mostly a setting for people that ignored the read me and how "preserve" works 😄

Notes on IPv4:
- This script is unable to detect if have a real public IP4 or if you suffer from [CG-NAT](https://desec.io)!

Notes on IPv6: 
- Watch out for IPv6 privacy extensions. Your host might have multiple IPv6 but use the none static IPv6 privacy extension enabled IPv6 for this script instead of the static one.
- Almost all ISP offer you a static /56 or /48 prefix, so you most likely should not need DynDNS for IPv6. 

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