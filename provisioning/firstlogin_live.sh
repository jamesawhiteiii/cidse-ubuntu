#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           firstlogin_live.sh
# Purpose:        FSE Ubuntu Client Configuration- First Login Live Script
# Notes:          Check /var/log/fse.log if you encounter any errors
#				  This script is called by firstboot.sh via WGET
#
#This does the following:
#####       * Initial variable setup
#####		* Ask user for new hostname
#####		* Register with Landscape
#####		* Disable autologin and configure the login screen

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

#####################################################################
# Display a banner                                                  #
#####################################################################
clear
echo " *****************************************************************************"
echo " *****************************************************************************"
echo " *********              FSE UBUNTU LIGHTWEIGHT CLIENT SETUP       ************"
echo " *****************************************************************************"
echo " *****************************************************************************"
echo "                View configuration logs at /var/log/fse.log                   "
echo " *****************************************************************************"

#####################################################################
# Set the hostname                                                  #
#####################################################################
echo " *****************************************************************************"
echo " *********                   SET HOSTNAME                   ******************"
echo " *****************************************************************************"
### Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)
### Display existing hostname
echo "The current hostname of this systems is $hostn"
### Ask for new hostname $newhost
echo " ****************************************************************************"
echo " ****************************************************************************"
echo " "
echo " Please enter the desired hostname for this system: "
read newhost
echo " *****************************************************************************"
echo " *****************************************************************************"
#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhost/g" /etc/hosts
sed -i "s/$hostn/$newhost/g" /etc/hostname
service hostname start
echo " *****************************************************************************"
echo " *****************************************************************************"
hostname $newhost
echo " Hostname has been updated to $newhost"

echo " **********************************************************************************"
### Write out to log
echo $(date) ${filename} SUCCESS: Hostname is $newhost >>/var/log/fse.log

clear
#####################################################################
# Register with Landscape                                           #
#####################################################################
echo " ********************************************************************************"
echo "*************           REGISTERING WITH LANDSCAPE           ********************"
echo "*************           landscape.fulton.ad.asu.edu          ********************"
echo "*********************************************************************************"

echo “Beginning Landscape Configuration”
landscape-config --computer-title $(hostname -f) --script-users nobody,landscape,root --silent

#Send to log file
echo $(date) ${filename} SUCCESS: FSE Landscape Registration Complete >> /var/log/fse.log




#####################################################################
# Disable autologin & configure login screen                        #
#####################################################################
echo " ********************************************************************************"
echo " ********    Disable autologin & configure the login screen            **********"
echo " ********************************************************************************"
echo " Please wait..."

if [ "${ver_chk}" ];
then
	# Disable autologin for 18.04
	rm /etc/gdm3/custom.conf
	mv /etc/gdm3/custom.conf.bak /etc/gdm3/custom.conf
	echo $(date) ${filename} SUCCESS: Gnome autologin disabled >> /var/log/fse.log
else
	echo “Copying Lightdm.conf”
	# Remove autologin version of lightdm
	rm /etc/lightdm/lightdm.conf
	# Download the lightdm file without autologin and with guest access disabled
	wget -O /etc/lightdm/lightdm.conf https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/${fse_env}/provisioning/lightdm.conf
	chown root:root /etc/lightdm/lightdm.conf
	chmod 644 /etc/lightdm/lightdm.conf
	echo $(date) ${filename} SUCCESS: FSE lightdm.conf copied, autologin disabled >> /var/log/fse.log
fi

#####################################################################
# Remove this script, firstlogin and the autostart for it           #
#####################################################################
rm /tmp/firstlogin_live.sh
rm /tmp/firstlogin.sh
rm /home/techs/.config/autostart/provisioning.desktop
mv /home/techs/.config/autostart/provisioning.desktop.bak rm /home/techs/.config/autostart/provisioning.desktop 

#####################################################################
# Log completion                                                    #
#####################################################################
echo $(date) ${filename} SUCCESS: ${filename} complete >> /var/log/fse.log

#####################################################################
# Restart GUI to complete process                                   #
#####################################################################
if [ "${ver_chk}" ];
then
        # Restart 18.04 GUI
		killall -3 gnome-shell
		
else
		# Restart 16.04/Earlier GUI
		service lightdm restart
fi

