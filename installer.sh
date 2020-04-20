#!/bin/bash
# Easy TeamSpeak 3 installer for Debian or CentOS based OS
#
# By mikho - https://github.com/mikho/TS3-Installer
# 

# Check for root account
if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
  exit 1
fi

# Ask the user if they accept the teamspeak license. Quit if not accepted
while true; do
read -p "Do you accept the Teamspeak License? [y/n]: " licensepermission
  if [[ "$licensepermission" == "y" ]]; then
    echo "You accepted the Teamspeak License."
    echo "You can view the license by using: cat /opt/ts3/LICENSE"
    break
  elif [[ "$licensepermission" = "n" ]]; then
    echo "Error: You did not accept the Teamspeak License. Quiting installation."
    exit 2
    break
  fi
done

# Check supported OS and install required packages
echo "Installing required packages"
if [ -e '/etc/redhat-release' ] ; then
  yum update -yes
  yum install wget sudo telnet bzip2 tar ca-certificates -yes 
elif [ -e '/etc/os-release' ] ; then
  apt-get update
  apt-get install -y wget sudo telnet bzip2 tar ca-certificates
else 
  echo "Can't figure out what distribution you are running, exiting"
  exit 2
  break
fi

# Check if packages were installed, else exit with error
CMDS="wget sudo telnet bzip2"
for i in $CMDS
do
	type -P $i &>/dev/null  && continue  || { echo "$i command not found. Computer says No."; exit 1; }
 done


# Get the internal IP of the server
pvtip=$( ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' )

# Get the external public IP of the server
pubip=$( wget -qO- http://ipinfo.io/ip )



# Gives user the internal ip for reference and ask for desired ports
echo "Your private internal IP is: $pvtip"
echo "If you are installing this on a NAT VPS, use your assigned ports."
read -p "Enter Voice Server port [9987]: " vport
while true; do
  if [[ "$vport" == "" ]]; then
    vport="9987"
    break
  elif ! [[ "$vport" =~ ^[0-9]+$ ]] || [[ "$vport" -lt "1" ]] || [[ "$vport" -gt "65535" ]]; then
    echo "Voice Server port invalid."
    read -p "Re-enter Voice Server port [9987]: " vport
  else
    break
  fi
done

read -p "Enter File Transfer port [30033]: " fport
while true; do
  if [[ "$fport" == "" ]]; then
    fport="30033"
    break
  elif ! [[ "$fport" =~ ^[0-9]+$ ]] || [[ "$fport" -lt "1" ]] || [[ "$fport" -gt "65535" ]]; then
    echo "File Transfer port invalid."
    read -p "Re-enter File Transfer port [30033]: " fport
  else
    break
  fi
done

read -p "Enter Server Query port [10011]: " qport
while true; do
  if [[ "$qport" == "" ]]; then
    qport="10011"
    break
  elif ! [[ "$qport" =~ ^[0-9]+$ ]] || [[ "$qport" -lt "1" ]] || [[ "$qport" -gt "65535" ]]; then
    echo "Server Query port invalid."
    read -p "Re-enter Server Query port [10011]: " qport
  else
    break
  fi
done

rapass=$( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 )
read -p "Enter Server Query Admin password [$rapass]: " apass
if [[ "$apass" == "" ]]; then
  apass=$rapass
fi

# Get latest TS3 server version
echo "-------------------------------------------------------"
echo "Detecting latest TeamSpeak 3 version, please wait..."
echo "-------------------------------------------------------"
ts3version=$(wget 'https://files.teamspeak-services.com/releases/server/' -q -O - --no-check-certificate | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | uniq | sort -r -V | head -n 1)
echo "Latest version found is: " $ts3version

# Get OS Arch and download correct packages
if [ "$(arch)" != 'x86_64' ]; then
    wget "https://files.teamspeak-services.com/releases/server/"$ts3version"/teamspeak3-server_linux_x86-"$ts3version".tar.bz2" --no-check-certificate -P /opt/ts3/
else
    wget "https://files.teamspeak-services.com/releases/server/"$ts3version"/teamspeak3-server_linux_amd64-"$ts3version".tar.bz2" --no-check-certificate -P /opt/ts3/
fi

# Create non-privileged user for TS3 server, and moves home directory under /etc
adduser --disabled-login --gecos "ts3server" ts3

# Extract the contents and give correct ownership to the files and folders
echo "------------------------------------------------------"
echo "Extracting TeamSpeak 3 Server Files, please wait..."
echo "------------------------------------------------------"
tar -xjf /opt/ts3/teamspeak3-server_linux*.tar.bz2 --strip 1 -C /opt/ts3/
rm -f /opt/ts3/teamspeak3-server_linux*.tar.bz2
chown -R ts3:ts3 /opt/ts3/

# Create autostart script
# Check if systemd or init
astart="$(ps --no-headers -o comm 1)"
if [ $astart == "init" ]; then
  cat > /etc/init.d/ts3server <<"EOF"
  #!/bin/sh
  ### BEGIN INIT INFO
  # Provides:          TeamSpeak 3 Server
  # Required-Start:    networking
  # Required-Stop:
  # Default-Start:     2 3 4 5
  # Default-Stop:      0 1 6
  # Short-Description: TeamSpeak 3 Server Daemon
  # Description:       Starts/Stops/Restarts the TeamSpeak 3 Server Daemon
  ### END INIT INFO

  set -e

  PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
  DESC="TeamSpeak 3 Server"
  NAME=ts3
  USER=ts3
  DIR=/opt/ts3/
  DAEMON=$DIR/ts3server_startscript.sh
  SCRIPTNAME=/etc/init.d/$NAME

  test -x $DAEMON || exit 0

  cd $DIR
  sudo -u ts3 ./ts3server_startscript.sh $1
EOF
chmod 755 /etc/init.d/ts3server
# Set TS3 server to auto start on system boot
update-rc.d teamspeak3 defaults
else # $astart <> "init" 
cat > /etc/systemd/system/ts3server.service <<"EOF"
[Unit]
Description=TeamSpeak 3 Server
Documentation=http://www.teamspeak.com/?page=literature
Wants=network.target
After=syslog.target network.target

[Service]
User=ts3
WorkingDirectory=/opt/ts3
Type=forking
ExecStart=/opt/ts3/ts3server_startscript.sh start
ExecStop=/opt/ts3/ts3server_startscript.sh stop
ExecReload=/opt/ts3/ts3server_startscript.sh reload
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

 # Set TS3 server to auto start on system boot
 systemctl enable ts3server
fi

# Assign right ports and password to TS3 server
sed -i 's/COMMANDLINE_PARAMETERS=""/COMMANDLINE_PARAMETERS="query_port='$qport' query_ip=0.0.0.0 default_voice_port='$vport' voice_ip=0.0.0.0 filetransfer_port='$fport' filetransfer_ip=0.0.0.0 serveradmin_password='$apass'"/' /opt/ts3/ts3server_startscript.sh

# Give user all the information
echo ""
echo ""
clear
echo "TeamSpeak 3 has been successfully installed!"
echo ""
echo ""
echo "Accepting the license..."
touch /opt/ts3/.ts3server_license_accepted
echo "Accepted license!"
echo "Automatically configuring ports..."
echo ""
echo "Voice server is available at $pubip:$vport"
echo ""
echo "The file transfer port is: $fport"
echo "The server query port is: $qport"
echo ""
read -p "Start the server now? [y/n]: " startopt
sleep 1
if [ "$startopt" == "y" ] || [ "$startopt" == "yes" ]; then
  if [ $astart == "init" ]; then
    /etc/init.d/ts3server start
  else
   service ts3server start
  fi   
  sleep 2
else
  echo "Run the following command to manually start the server:"
   if [ $astart == "init" ]; then
    echo "/etc/init.d/ts3server start"
  else
   echo "service ts3server start"
  fi
fi
  echo "After first start,"
  echo "find your private token by running the following command:"
  echo "cat /opt/ts3/logs/\$(ls -t1 /opt/ts3/logs | tail -1)"

exit 0
