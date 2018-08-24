#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           .firstboot.sh
# Purpose:        FSE Ubuntu Client Configuration- First Login Script
# Notes:          Check /var/log/fse.log if you encounter any errors

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

# Set filename variable for use in logging
filename=$(echo $0 | rev | cut -d'/' -f1 | rev)

#the lsb-release file has information on the Ubuntu version
#the first grep returns the line containing the version number
#the second grep determins if it 18.04

ver_chk=$(cat /etc/lsb-release | grep RELEASE | grep 18.04)

# ver_chk will return empty/false if not 18.04

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
#######################           Configure Login Screen           #######################
##########################################################################################
##########################################################################################



if [ "${ver_chk}" ];
then
        echo $(date) ${filename} LOG: Version is 18.04, performing 18.04 specific tasks >> /var/log/fse.log
        sudo apt-get remove gnome-initial-setup -y
        mv /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak
        cp /install/fse/scripts/1804/custom.conf /etc/gdm3/custom.conf
        chown root:root /etc/gdm3/custom.conf
        chmod 644 /etc/gdm3/custom.conf
		echo $(date) ${filename} SUCCESS: 18.04 login configured >> /var/log/fse.log
		
else
		echo $(date) ${filename} LOG: Version is earlier than 18.04, performing 16.04 & earlier tasks >> /var/log/fse.log
		### Sets the LightDm to auto login
		### 14.04 and 16.04 System Only
		cp /install/fse/login/lightdm.conf /etc/lightdm/
		chown root:root /etc/lightdm/lightdm.conf
		chmod a+x /etc/lightdm/lightdm.conf
		echo $(date) ${filename} SUCCESS: 16.04 login configured >> /var/log/fse.log
fi

##########################################################################################
######################                   CIFS-UTILS                  #####################
##########################################################################################

apt install cifs-utils -y
echo $(date) ${filename} SUCCESS: CIFS-UTILS Installed >> /var/log/fse.log
##########################################################################################
######################                      GKSU                     #####################
##########################################################################################

apt-get install gksu -y
echo $(date) ${filename} SUCCESS: GKSU Installed >> /var/log/fse.log
##########################################################################################
############################               CLAMAV                    #####################
##########################################################################################

apt-get install clamav-daemon -y
apt-get install clamtk -y
echo $(date) ${filename} SUCCESS: Clam-AV installed >> /var/log/fse.log
##########################################################################################
#######################             PBIS Client Repo        ##############################
##########################################################################################

wget -O - http://repo.pbis.beyondtrust.com/apt/RPM-GPG-KEY-pbis | sudo apt-key add - 
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
echo $(date) ${filename} SUCCESS: Open SSH Server installed >> /var/log/fse.log

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
echo $(date) ${filename} SUCCESS: Techs profile copied and configured >> /var/log/fse.log

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
echo $(date) ${filename} SUCCESS: Host file modified for Landscape >> /var/log/fse.log
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
echo $(date) ${filename} SUCCESS: Landscape client config copied >> /var/log/fse.log



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

# Restart GUI environment for 18.04/16.04 and earlier
# ver_chk will return empty/false if not 18.04

if [ "${ver_chk}" ];
then
        # Restart 18.04 GUI
		killall -3 gnome-shell
		
else
		# Restart 16.04/Earlier GUI
		service lightdm restart
fi