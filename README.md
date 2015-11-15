## NAT TS3 Installer
This installer will automatically install TeamSpeak 3 onto your NAT VPS, and automatically configure the ports to the ones you specify.

### How do I install?
To install TeamSpeak 3 automatically, run this command and follow the prompt.

``` wget http://git.io/nat_ts3 --no-check-certificate -O /tmp/nat_ts3.sh && bash /tmp/nat_ts3.sh```

### I can't remember the port number, help!
You can also set up SVR records with your dns provider so you can use your hostname instead and do not have to remember your port number. For instructions on how to have this set up, please visit the <a href="https://support.teamspeakusa.com/index.php?/Knowledgebase/Article/View/293/12/does-teamspeak-3-support-dns-srv-records" target="_blank">TeamSpeak3 support page</a>.

### Where do I get a server?
This script will run on any vps server as long as it has root and ipv4 access. NAT IPv4 VPS is how this script was born.<br />
Check out the <a href="http://lowendspirit.com/locations.html" target="_blank">LowEndSpirit</a> project to get a server for just €2 per year.

### Does my server have a license?
No. Only the barebone server will be installed, no license will be included. You can, however, use the server as is for personal usage, up to 32 concurrent clients.<br />
If you need to upload your own license, you can upload your "licensekey.dat" to ```/etc/ts3/``` and type ```/etc/init.d/teamspeak3 restart``` to have the key registered.

### More info please.
Current TeamSpeak 3 server version: 3.0.11.4<br />
Tested on Debian 7 32/64bit and Debian 8 64bit.
