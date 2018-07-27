#!/bin/bash

# Set filename variable for use in logging
filename=$(echo $0 | rev | cut -d'/' -f1 | rev)

##########################################################################################
##########################################################################################
##########################################################################################
#  UBUNTU: FSE CLIENT FIRST BOOT INSTALLER
##########################################################################################
#				                              version 1.0
##########################################################################################
#
#				                        created by: James White
#				                                 CIDSE
#				                        Arizona State University
#				                        last updated Feb 14, 2018
#
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
sleep 10
##########################################################################################
##########################################################################################
##########################################################################################
######################                               		         #####################
######################           	UBUNTU FSE SECURITY              #####################
######################                 CONFIGURATION                 #####################
##########################################################################################
##########################################################################################

#####################################################################
# Checking for internet connectivity                                #
#####################################################################
if [[ "$(ping -c 1 8.8.8.8 | grep '100% packet loss' )" != "" ]]; then
    echo "Failed to connect to the internet"
    echo "Check your connection and then log out and log in to restart"
    echo "This script will close in 20 seconds"
    sleep 20
    echo $(date) ${filename} ERROR: No network connectivity, unable to reach the internet, log out and back in to restart the setup process >> /var/log/fse.log
    exit 1
else
    echo "Network connection present"
    echo
fi

##########################################################################################
##########################################################################################
#######################              CLIENT PATCHING                ######################
##########################################################################################

#Avahi-Daemon Patching
cp /install/fse/patch/avahi/avahi-daemon.conf
echo $(date) ${filename} SUCCESS: Avahi-Daemon patching completed >> /var/log/fse.log

##########################################################################################
##########################################################################################
#######################           Configure Login Screen           #######################
##########################################################################################
##########################################################################################
### Sets the LightDm to auto login
### 14.04 and 16.04 System Only
cp /install/fse/login/lightdm.conf /etc/lightdm/
chown root:root /etc/lightdm/lightdm.conf
chmod a+x /etc/lightdm/lightdm.conf
echo $(date) ${filename} SUCCESS: Login Screen Configured >> /var/log/fse.log

#this file will do two things
	#1. remove welcome screen
	#2. configure auto login

#the lbs-release file has information on the Ubuntu version
#the first grep returns the line containing the version number
#the second grep determins if it 18.04

ver_chk=$(cat /etc/lsb-release | grep RELEASE | grep -q 18.04)

# ver_chk will return as a 0 if the grep is matched
# If no match, it will return a 1

if ${ver_chk};
then
        echo 'this is anything but 18'
else
        echo 'this is 18'
        sudo apt-get remove gnome-initial-setup -y
        mv /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak
        cp /install/fse/scripts/1804/custom.conf /etc/gdm3/custom.conf
        chown root:root /etc/gdm3/custom.conf
        chmod 644 /etc/gdm3/custom.conf
fi


##########################################################################################
#######################             PBIS Client Repo        ##############################
##########################################################################################

wget -O - http://repo.pbis.beyondtrust.com/apt/RPM-GPG-KEY-pbis|sudo apt-key add - 
sudo wget -O /etc/apt/sources.list.d/pbiso.list http://repo.pbis.beyondtrust.com/apt/pbiso.list 
sudo apt-get update
echo $(date) ${filename} SUCCESS: PBIS-OPEN Repo Added >> /var/log/fse.log

##########################################################################################
##########################           Install PBIS Client        ##########################
##########################################################################################

apt-get install pbis-open -y
echo $(date) ${filename} SUCCESS: PBIS-OPEN Installed >> /var/log/fse.log


##########################################################################################
##########################     Install Landscape Client         ##########################
##########################################################################################

apt install landscape-client -y
echo $(date) ${filename} SUCCESS: Landscape-Client Installed >> /var/log/fse.log

##########################################################################################
##########################     Install Open SSH Server          ##########################
##########################################################################################

apt-get install openssh-server -y
echo $(date) ${filename} SUCCESS: Open SSH Server Installed >> /var/log/fse.log

##########################################################################################
##########################################################################################
##########################################################################################
######################                               		         #####################
######################            PREPARE FOR PROVISIONING           #####################
######################                 CONFIGURATION                 #####################
##########################################################################################
##########################################################################################
##########################################################################################

rm -R /home/techs/.config/
cp -a /install/fse/profiles/techs/.config/ /home/techs/.config/
chown -R techs:techs /home/techs/
echo $(date) ${filename} SUCCESS: Techs Profile Configured >> /var/log/fse.log

##########################################################################################

##########################################################################################
##########################################################################################
######################	             PRE-CONFIGURE                       #################
######################	     	    LANDSCAPE CLIENT       	             #################
##########################################################################################

##########################################################################################
##################################  CONFIGURE .host FILE     #############################
##########################################################################################

# Add entry to hosts file for Landscape server
echo 10.220.67.136 landscape.fulton.asu.edu >> /etc/hosts
echo $(date) ${filename} SUCCESS: Host File Modified >> /var/log/fse.log
##########################################################################################

##########################################################################################
##########################################################################################
##########################   Configure /etc/landscape/ directory  ########################
##########################################################################################

##### Copying Landscape License File #####
cp /install/fse/landscape/license.txt /etc/landscape/

##### Copy Landscape SSL Cert to /etc/landscape #####
cp /install/fse/landscape/landscape_server.pem /etc/landscape/

##########################################################################################
################       Make backup of default client.conf    #############################
##########################################################################################

mv /etc/landscape/client.conf /etc/landscape/client.conf.bak

##########################################################################################
################ Write Client.txt data to the client.conf file ###########################
##########################################################################################

cp /install/fse/landscape/client.conf /etc/landscape/
echo $(date) ${filename} SUCCESS: FSE Client Configuration Complete >> /var/log/fse.log



##########################################################################################
##########################################################################################
######################         Configure First Run Scripts       	######################
##########################################################################################

cp /install/fse/scripts/firstlogin.sh /tmp/firstlogin.sh
echo $(date) ${filename} SUCCESS: First login configured >> /var/log/fse.log

##########################################################################################
##########################################################################################
###########################    Set Temporary FSE Background        #######################
##########################################################################################

rm /usr/share/backgrounds/warty-final-ubuntu.png
cp /install/fse/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/
chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png
echo $(date) ${filename} SUCCESS: Set FSE Deployment Background  >> /var/log/fse.log
##########################################################################################
##########################################################################################
################################        CLEANUP         ##################################
##########################################################################################
##########################################################################################
##########################################################################################

echo $(date) ${filename} SUCCESS: Completed  >> /var/log/fse.log

##########################################################################################

service lightdm restart





