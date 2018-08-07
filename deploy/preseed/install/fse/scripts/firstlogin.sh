#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           firstlogin.sh
# Purpose:        FSE Ubuntu Client Configuration- First Login Script
# Notes:          Check /var/log/fse.log if you encounter any errors
#
#This does the following:
#FSE Client Configuration:
#####       * Checks for internet connectivity
#####       * Verifies the script is running as root
#####       * Pulls FSE

#####################################################################
# Display some information                                          #
#####################################################################

# Get the filename for logging
filename=$(echo $0 | rev | cut -d'/' -f1 | rev)

##########################################################################################
##########################################################################################
##########################################################################################
echo "***********************************************************************************"
echo "***********************************************************************************"
echo "*************          BEGINNING FSE CLIENT CONFIGURATION          ****************"
echo "***********************************************************************************"
echo "***********************************************************************************"
echo "View configuration logs are located at /var/log/fse.log"
echo "***********************************************************************************"

#####################################################################
# Checking for internet connectivity                                #
#####################################################################
if [ "$(ping -c 1 8.8.8.8 | grep '100% packet loss' )" != "" ]; then
echo "Failed to connect to the internet"
echo "Please check your network connection,then log out and back in as techs to restart configuration process"
echo "This script will close in 20 seconds"
sleep 20
#Send to log file
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
##Send to log file
echo $(date) ${filename} SUCCESS: FSE Client Configuration Complete >> /var/log/fse.log

##########################################################################################
##################    GET DEPARTMENT SPECIFIC CONFIGURATION       ########################
##########################################################################################
#Send to log file
echo $(date) ${filename} Beginning Department Specific Provisioning >> /var/log/fse.log
#
# Get lastest provisioning script from repo and execute
cd /tmp
wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/provisioning/provisioning.sh
chmod u+x /tmp/provisioning.sh
bash /tmp/provisioning.sh --verbose

##Send to log file
echo $(date) ${filename} SUCCESS: Department Specific Provisioning Complete >> /var/log/fse.log

echo "***********************************************************************************"
echo "*************              CLIENT CONFIGURATION COMPLETE          *****************"
echo "***********************************************************************************"

echo "***********************************************************************************"
echo "****          An email has been sent to your Systems Administrator!            ****"
echo "***********************************************************************************"
##########################################################################################

#sleep 30

#reboot



