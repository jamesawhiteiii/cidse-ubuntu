#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           firstlogin.sh
# Purpose:        FSE Ubuntu Client Configuration- First Login Script
# Notes:          Check /var/log/fse.log if you encounter any errors
#
#This does the following:
#####       * Initial variable setup
#####		* Check for internet connectivity
#####       * Verifies the script is running as root
#####		* Sets user background for 18.04
#####       * WGET for firstlogin_live.sh

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
	echo ERROR: No network connectivity during ${filename} initial run. Please log out and log in to restart the script >> /home/techs/Desktop/${filename}-ERROR.log
    echo $(date) ${filename} ERROR: No network connectivity, unable to reach the internet, log out and back in to restart the setup process >> /var/log/fse.log
    exit 1
else
    echo "Network connection present"
    echo
fi

#####################################################################
# Check for root privileges                                         #
#####################################################################
if [ "$(id -u)" != "0" ]
then
echo "This script must be run with root privileges"
#Send to log file
echo $(date) ${filename} ERROR: Unable to continue without root privileges, log out and back in to restart the setup process >> /var/log/fse.log
exit 1
fi

######################################################################
# Set background for 18.04+                                          #
######################################################################
# Gnome in 18.04+ doesn't allow background to be set during firstboot script
if [ "${ver_chk}" ];
then
        # Set the 18.04 pitchfork/provisioning background
		gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/warty-final-ubuntu.png
fi

######################################################################
# Wget firstlogin_live                                               #
######################################################################
#Send to log file
echo $(date) ${filename} Beginning WGET of firstlogin_live.sh >> /var/log/fse.log

# Get lastest firstlogin_live script from repo and execute
wget -O /tmp/firstlogin_live.sh https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/${fse_env}/provisioning/firstlogin_live.sh
chmod u+x /tmp/firstlogin_live.sh
bash /tmp/firstlogin_live.sh --verbose

##Send to log file
echo $(date) ${filename} SUCCESS: Department Specific Provisioning Complete >> /var/log/fse.log

echo "***********************************************************************************"
echo "*************              CLIENT CONFIGURATION COMPLETE          *****************"
echo "***********************************************************************************"

echo "***********************************************************************************"
echo "****          An email has been sent to your Systems Administrator!            ****"
echo "***********************************************************************************"
##########################################################################################




