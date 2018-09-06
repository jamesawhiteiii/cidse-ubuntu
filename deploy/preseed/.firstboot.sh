#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           .firstboot.sh
# Purpose:        FSE Ubuntu Client Configuration - Static First Boot Script
# Notes:          Check /var/log/fse.log if you encounter any errors
#				  This script will run at every system boot until you remove
#                 the /etc/rc.local file which calls this script
#
#This does the following:
#####       * Initial variable setup
#####		* Check for internet connectivity
#####		* WGET the firstboot_live.sh script

#####################################################################
# Initial variable setup                                            #
#####################################################################

# Set if this script is in 'devtest' branch or 'master' branch
fse_env=$(cat /install/fse/fse_env)

# Set variable with filename for use in logging
filename=$(echo $0 | rev | cut -d'/' -f1 | rev)

# Set variable with what version of Ubuntu this installation is running
ver_chk=$(cat /etc/lsb-release | grep RELEASE | grep 18.04)

# ver_chk will return empty/false if not 18.04
# the lsb-release file has information on the Ubuntu version
# the first grep returns the line containing the version number
# the second grep determins if it 18.04

#####################################################################
# Checking for internet connectivity                                #
#####################################################################

# Add a pause to allow network connection to come alive
sleep 10

# Now test the network
if [[ "$(ping -c 1 8.8.8.8 | grep '100% packet loss' )" != "" ]]; then
    echo "Failed to connect to the internet"
    echo "Check your connection and then log out and log in to restart"
    echo "This script will close in 20 seconds"
    sleep 20
	echo ERROR: No network connectivity during ${filename} initial run. Please reboot to restart the script >> /home/techs/Desktop/${filename}-ERROR.log
    echo $(date) ${filename} ERROR: No network connectivity, unable to reach the internet, reboot to restart the setup process >> /var/log/fse.log
    exit 1
else
    echo "Network connection present"
    echo
fi

######################################################################
# Wget firstboot_live.sh                                             #
######################################################################
#Send to log file
echo $(date) ${filename} Beginning WGET of firstboot_live.sh >> /var/log/fse.log

# Get lastest firstlogin_live script from repo and execute
wget -O /tmp/firstlogin_live.sh https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/${fse_env}/provisioning/firstboot_live.sh
chmod u+x /tmp/firstboot_live.sh
bash /tmp/firstboot_live.sh --verbose
