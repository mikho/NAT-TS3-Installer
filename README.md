## NAT TS3 Installer
This installer will automatically install the latest version of TeamSpeak 3 onto your NAT VPS, and automatically configure the ports to the ones you specify.

It will also install dependency packages.

### How do I install?
To install TeamSpeak 3 automatically, run this command and follow the prompt.

``wget https://raw.githubusercontent.com/mikho/TS3-Installer/master/installer.sh --no-check-certificate -O /tmp/ts3installer.sh && bash /tmp/ts3installer.sh``

### Requirements
Should work on both OpenVZ and KVM, as well as Dedicated. No promises :) 
Let me know if something breaks.

### Will this script work with VPS with dedicated IPs (all ports available)?
Yes, everything will work! Just use 9987 (default port) as your voice server port, 30033 as your file transfer port, and 10011 as your server query port. Of course if you want custom ports, you can set them to whatever you want as long as you have access to those ports and are opened in your firewall rules.

### I can't remember the port number, help!
You can also set up SVR records with your dns provider so you can use your hostname instead and do not have to remember your port number. For instructions on how to have this set up, please visit the <a href="https://support.teamspeakusa.com/index.php?/Knowledgebase/Article/View/293/12/does-teamspeak-3-support-dns-srv-records" target="_blank">TeamSpeak3 support page</a>.

### Does my server have a license?
No. Only the barebone server will be installed, no license will be included. You can, however, use the server as is for personal usage, up to 32 concurrent clients.<br />
If you need to upload your own license, you can upload your "licensekey.dat" to ```/opt/ts3/``` and restart the service for the new license key to take effect.

### Where do I get a server?
This script will run on any vps server as long as it has root and ipv4 access. VPS with NAT'd IPv4 works just as well.<br />

##### mrVM.net - NAT VPS - as low as $4/year  #####

##### <a href="https://clients.mrvm.net/cart.php?gid=11" target="_blank">Europe</a> #####
* Milan, IT
* Sofia, BG
* Nuremberg, DE
* Reihns, FR
* Sandefjord,NO 

##### <a href="https://clients.mrvm.net/cart.php?gid=19" target="_blank">America</a> #####
* Kansas City, Missouri
* Lenoir, Noth Carolina
* Berkeley Springs, West Virgina 
* Las Vegas, Nevada
* Seattle, Washington
* New York, New York

##### <a href="https://clients.mrvm.net/cart.php?gid=20" target="_blank">Rest of the World</a> #####
* Sydney, Australia
* Perth, Australia
* Singapore, Singapore

### More info please.
This script uses init.d, no support for systemd, yet.<br />
!! Not Tested yet !!<br />

Forked from https://github.com/bosscoder/NAT-TS3-Installer
