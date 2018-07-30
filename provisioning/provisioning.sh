#!/bin/bash
#######################################################################
# Project           : FSE Ubuntu Deployment
#
# Program name      : provisioning.sh
# Author            : James White III
# Contributors
# Date created      : 07 24 2018
#
# Purpose           : Apply configuration to new Ubuntu Clients
#
##########################################################################################
##########################################################################################
##########################################################################################

##########################################################################################
#######################              CLIENT UPDATES                 ######################
##########################################################################################

##########################################################################################
#######################              CLIENT PATCHING                ######################
##########################################################################################

#Avahi-Daemon Patching
#cp /install/fse/patch/avahi/avahi-daemon.conf /etc/avahi/
#echo $(date) ${filename} SUCCESS: Avahi-Daemon patching completed >> /var/log/fse.log

##########################################################################################
######################            MOUNT SOURCE FILESHARE	         #####################
##########################################################################################

echo “Installing CIFS-UTILS”
apt-get install cifs-utils -y

echo “Making New Source Directory”
mkdir /mnt/source/

echo “Mounting CIDSE-FS-01”
mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!
/
##########################################################################################

##########################################################################################


##########################################################################################
##########################             ADD ADMINISTRATORS           ######################
##########################################################################################


##########################################################################################
##########################                ADD PRINTERS              ######################
##########################################################################################




##########################################################################################
##########################################################################################
###############             ALL COMMON SOFTWARE CAN BE FOUND Here:      ##################
###############                   /mnt/source/linux/software/common     ##################
###############       cidse-fs-01.cidse.dhcp.asu.edu/linux/software       ###################
##########################################################################################

#echo "Installing MATLAB2017a"
#sh /mnt/source/linux/ubuntu/software/common/matlab/R2017a/install_matlab2017a.sh

#echo "Installing VMWARE 14 with Windows 10 VM"
#sh /mnt/source/linux/ubuntu/software/common/vmware/14/install_vmware14.0.0.sh


##########################################################################################
##########################################################################################
##################          INSTALL DEPARTMENT SPECIFIC SOFTWARE               ###########
##################            CIDSE SPECIFIC SOFTWARE CAN BE FOUND Here:       ###########
##################                 /mnt/source/linux/software/cidse            ###########
##################      cidse-fs-01.cidse.dhcp.asu.edu/linux/software/cidse       ###########
##########################################################################################








##########################################################################################
##########################################################################################
###########################                EXTRA PICKLES                ##################
##########################################################################################
##########################################################################################




##########################################################################################
###########################    COPY TECHS PROFILE TEMPLATE   #############################
##########################################################################################
#rm -r /home/techs/
#cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/techs/ /home/
#chown -R techs /home/techs/


##########################################################################################
############################   COPY DEFAULT USER PROFILE  ################################
##########################################################################################

#cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/default/. /etc/skel; \


##########################################################################################
##############    Copy the Fulton background to the default location and file   ##########
##########################################################################################

echo “Copying CIDSE 2018 Wallpaper”
rm /usr/share/backgrounds/warty-final-ubuntu.png
cp /mnt/source/linux/ubuntu/config/cidse/workstation/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/
chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png


##########################################################################################
############################   Set Login Configuration     ###############################
# Lightdm.conf file is set to allow TECHS to auto login
#echo “Copying Lightdm.conf”
#rm /etc/lightdm/lightdm.conf
#cp /mnt/source/linux/ubuntu/config/cidse/workstation/login/lightdm.conf /etc/lightdm/lightdm.conf
#chown root:root /etc/lightdm/lightdm.conf
#chmod a+x /etc/lightdm/lightdm.conf


##########################################################################################
############################         Copy Next Startup Script         ######################
##########################################################################################

#mkdir /cidseit/
#mkdir /cidseit/login/
#mkdir /cidseit/login/scripts/
#mkdir /cidseit/login/scripts/startup/
#chown -R techs /cidseit/

#Places permanent rc.local file in /etc/
#cp /mnt/source/linux/ubuntu/config/cidse/workstation/login/scripts/startup/rc.local /etc/rc.local
#chmod +x /etc/rc.local


#################################################################################################
#################################################################################################
###############################                 CLEAN UP                #########################
#################################################################################################
#################################################################################################
#rm /home/techs/Desktop
#mkdir /var/log/fse/cidse
#touch /var/log/fse/cidse/workstation_config.txt

echo "CLIENT CONFIGURATION COMPLETE"

sleep 10
#reboot


