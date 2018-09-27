#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           firstboot_live.sh
# Purpose:        FSE Ubuntu Client Configuration - Live Downloaded First Boot Script
# Notes:          Check /var/log/fse.log if you encounter any errors
#				  This script is called by firstboot.sh via WGET
#
#This does the following:
#####       * Initial variable setup
#####		* Setup 'techs' automatic login
#####		* Install and prepare the Landscape client
#####		* Install openssh-server
#####		* Wget firstlogin_live.sh and set for autostart on login
#####		* Set the FSE pitchfork/provisioning background
#####		* Reload the GUI which then will proceed to autologin

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
# Set FSE pitchfork/provisioning background                         #
#####################################################################
# Note: This won't work on 18.04+
# There is a portion of firstlogin that sets the wallpaper for 18.04

rm /usr/share/backgrounds/warty-final-ubuntu.png
cp /install/fse/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/
chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png

echo $(date) ${filename} SUCCESS: Set FSE Deployment Background for 16.04 and earlier  >> /var/log/fse.log

#####################################################################
# Set up auto login for techs account                               #
#####################################################################
# Test which version is running
# Then run appropriate commands for that version
if [ "${ver_chk}" ];
then
        echo $(date) ${filename} LOG: Version is 18.04, performing 18.04 autologin setup >> /var/log/fse.log
        # Remove Gnome welcome popup
		sudo apt-get remove gnome-initial-setup -y
		# Setup autologin for 'techs' account
        mv /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak
        cp /install/fse/autologin/custom.conf /etc/gdm3/custom.conf
        chown root:root /etc/gdm3/custom.conf
        chmod 644 /etc/gdm3/custom.conf
		echo $(date) ${filename} SUCCESS: 18.04 login configured >> /var/log/fse.log
		
else
		echo $(date) ${filename} LOG: Version is earlier than 18.04, performing 16.04 autologin setup >> /var/log/fse.log
		### Sets the LightDm to auto login
		### 14.04 and 16.04 System Only
		rm /etc/lightdm/lightdm.conf
		cp /install/fse/autologin/lightdm.conf /etc/lightdm/
		chown root:root /etc/lightdm/lightdm.conf
		chmod 644 /etc/lightdm/lightdm.conf
		echo $(date) ${filename} SUCCESS: 16.04 login configured >> /var/log/fse.log
fi

#####################################################################
# Install and prepare Landscape client                              #
#####################################################################
# Install the package
apt-get install landscape-client -y

# Copy the Landscape License File
cp /install/fse/landscape/license.txt /etc/landscape/

# Copy Landscape SSL Cert to /etc/landscape
cp /install/fse/landscape/landscape_server.pem /etc/landscape/

# Add entry to hosts file for Landscape server
echo 10.220.67.136 landscape.fulton.asu.edu >> /etc/hosts

# Backup default config file
mv /etc/landscape/client.conf /etc/landscape/client.conf.bak

# Copy new FSE client config file
cp /install/fse/landscape/client.conf /etc/landscape/

echo $(date) ${filename} SUCCESS: Landscape-Client installed and prepared >> /var/log/fse.log

#####################################################################
# Install Openssh-Sever                                             #
#####################################################################
apt-get install openssh-server -y
echo $(date) ${filename} SUCCESS: Open SSH Server installed >> /var/log/fse.log

#####################################################################
# Install curl                                                      #
#####################################################################
apt-get install curl -y
echo $(date) ${filename} SUCCESS: curl installed >> /var/log/fse.log

#####################################################################
# Install pbis-open                                                 #
#####################################################################

wget -O - http://repo.pbis.beyondtrust.com/apt/RPM-GPG-KEY-pbis | sudo apt-key add - 
sudo wget -O /etc/apt/sources.list.d/pbiso.list http://repo.pbis.beyondtrust.com/apt/pbiso.list 
sudo apt-get update
echo $(date) ${filename} SUCCESS: PBIS-OPEN Repo Added >> /var/log/fse.log

apt-get install pbis-open -y
echo $(date) ${filename} SUCCESS: PBIS-OPEN Installed >> /var/log/fse.log

#####################################################################
# Wget and set up firstlogin_live.sh autostart                      #
#####################################################################
#Send to log file
echo $(date) ${filename} Beginning WGET of firstlogin_live.sh >> /var/log/fse.log

# Get lastest firstlogin_live script from repo and execute
wget -O /tmp/firstlogin_live.sh https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/${fse_env}/provisioning/firstlogin_live.sh
chmod u+x /tmp/firstlogin_live.sh

# Create the autostart directory if it doesn't exists
mkdir /home/techs/.config/autostart

# Backup the original file (if it exists)
mv /home/techs/.config/autostart/provisioning.desktop /home/techs/.config/autostart/provisioning.desktop.bak

# Copy FSE version with firstlogin.sh autostart
cp -a /install/fse/autologin/provisioning.desktop /home/techs/.config/autostart/provisioning.desktop

echo $(date) ${filename} SUCCESS: firstlogin_live.sh autostart setup via /home/techs/.config/autostart/provisioning.desktop >> /var/log/fse.log

#####################################################################
# Restart GUI to proceed to auto login and continue                 #
#####################################################################

if [ "${ver_chk}" ];
then
        # Restart 18.04 GUI
		killall -3 gnome-shell
		
else
		# Restart 16.04/Earlier GUI
		service lightdm restart
fi

#####################################################################
# Remove this script and the autostart for it                       #
#####################################################################

rm /etc/rc.local
rm /tmp/firstboot_live.sh
echo $(date) ${filename} SUCCESS: ${filename} finished, removed and disabled from autostart  >> /var/log/fse.log
