# deSEC_DynDNS

**deSEC_DynDNS** is a simple DynDNS script for [deSEC.io](https://desec.io) that updates your DNS records only when your IP address changes.  

This script depends on **curl** and **dig** (from `bind-tools` on some systems).  

Tested on **Debian 12**, **Ubuntu 24.04.2 LTS**, **macOS 15.4.1**, and **OPNsense 25.1.5 (FreeBSD 14.2)**  

Feel free to contribute support for other environments, improvements, suggestions or correct my spelling mistakes :blush:    

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
Make sure that you have already created the A and/or AAAA records, since the auth token is by default not allowed to do that.  

Edit the domain and the token in the script with an editor you like. I use nano as an example.  
```bash
nano deSEC_DynDNS.sh
```
### Update logic of deSEC
By default this script behaves like the deSEC Update URL.    
If there is an IPv4 or IPv6 detected, it will create A and/or AAAA record(s).    
On the other hand, if IPv4 or IPv6 isn't detected, it will remove the corresponding records!   
Yes, even records you manually created on the webGUI will be removed!  
Resoning for that behavior is that if you host looses an IP, you probably also want to delete the record.  
This could potentially help you even noticing that there is a problem.  
If you don't like that behavior, you can use the preserve option.  
That way, it will leave the IPv4 or IPv6 untouched.  

### Preserve option
This will set the update URL to preserve, thous not touching your current record.
It will also disable checks for that protocol, since they are no longer needed when preserving the IP.  

### Command paths
For Debian and Ubuntu the paths should already be correct.
For OPNsense and macOS, you have to adjust them. 

### Disable a protocol
If you for whatever obscure reasons don't want to enable a protocol, you can disable it.  

## Test your config
To test your config, run the script:  
```bash
./deSEC_DynDNS.sh
```

## run it automatically
Depending on your OS, there are different way to repeatedly run your script.  
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
SSH into your OPNsense and press the option 8 to enter the shell.  
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
save and exit by pressing escape -> : -> wq -> enter

restart configd (or even better, reboot OPNsense)
```bash
service configd restart
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

