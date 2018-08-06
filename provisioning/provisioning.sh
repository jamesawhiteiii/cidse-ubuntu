#!/bin/bash
#######################################################################
# Project           : FSE Ubuntu Deployment
#
# Program name      : provisioning.sh
# Author            : James White III
# Contributors
# Date created      : 07 24 2018
#
# Purpose           : Apply department specific configuration to new Ubuntu Clients
#
##########################################################################################
##########################################################################################
##########################################################################################


#####################################################################
# Dependencies Check                                                #
#####################################################################
# DMIDECODE
#   Used for reading asset tag and BIOS information)
#   More information: 
#   https://www.tecmint.com/how-to-get-hardware-information-with-dmidecode-command-on-linux/
#   Also 'man dmidecode'

if [ -z "$(command -v dmidecode)" ]
then
	echo "dmidecode not installed, installing now"
	apt-get install dmidecode -y
fi

#####################################################################
# Obtain Asset Tag | Hostname                                       #
#####################################################################

# Attempt to retrieve asset tag from BIOS via dmidecode
asset_tag=$(dmidecode | grep Asset | uniq | cut -d" " -f3 | grep "^[0-9]\{7\}" | awk 'length($1) == 7' | uniq)

# Check Asset Tag against ASU format, ask for hostname if it doesn't match
if [[ ${asset_tag} =~ [0-9]{7}$ ]]
then
	new_hs=en${asset_tag}l
else
	echo "Asset Tag not set properly in BIOS, or does not match proper format"
	echo "Proper format is en0001234l where 0001234 is the ASU Asset Tag #"
	read -p "Please specify the new hostname followed by [ENTER]: " new_hs
fi

#####################################################################
# Set Hostname                                                      #
#####################################################################
current_hs=$(hostname)
echo "Current hostname is: " ${current_hs}
echo "Hostname to be set as:" ${new_hs}
read -p "Proceed with change? [y|n]:" user_choice

if [ ${user_choice} == "y" ]
then
	hostnamectl set-hostname ${new_hs}
	sed -i "s/${current_hs}/$(hostname)/g" /etc/hosts
	sed -i "s/localhost/$(hostname)/g" /etc/hosts
	echo "Hostname updated succesfully to "$(hostname)
else
	echo "Hostname not updated"
	echo "Log out and log back in restart the setup process"
	echo "This window will close in 20 seconds"
	echo $(date) ${filename} WARNING: No hostname was specified, causing the script to exit, log out and back in to restart the setup process  >> /var/log/fse.log
	sleep 20
	exit 1
fi

##########################################################################################
#Send to log file
echo $(date) ${filename} SUCCESS:Hostname updated to $(hostname) >> /var/log/fse.log

##########################################################################################
############################        SET ASU OWNER (ASURITE ID)    ########################
##########################################################################################
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " "
echo "                        Who is the owner of this system ?"
echo " "
echo "   *** Note: The system "owner" is the Faculty member who purchased the device ***"
echo " "
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " "
read -p "Please enter the owners ASURITE ID, followed by [ENTER]: " fse_owner
echo  "${fse_owner}" >> /etc/fse.owner

#Send to log file
echo $(date) ${filename} SUCCESS: ${fse_owner} owns this system >>/var/log/fse.log

##########################################################################################
############################               CONFIGURE          ############################
############################            ACTIVE DIRECTORY          ########################
##########################################################################################
##########################################################################################

##########################################################################################
############################	      CONFIGURE PBIS OPEN         ########################
##########################################################################################

echo " **********************************************************************************"
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************                 **WARNING**                   **********************"
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************      ALL NEW SYSTEMS MUST BE PRE-STAGED       **********************"
echo " *************         WITHIN ACTIVE DIRECTORY               **********************"
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************         PLEASE VERIFY THAT THE DEVICE         **********************"
echo " *************     IS IN THE PROPER OU BEFORE PROCEEDING     **********************"
echo " **********************************************************************************"
##########################################################################################
##############################    Verify AD PreStage    ##################################
##########################################################################################
#Requires the technician to verify whether or not the computer has been prestaged in AD.  #
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " "
read -p " *  Has this computer already been pre-staged in Active Directory? (Y)es/(N)o?  " choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "****************************************************************************"
        echo "****************************************************************************"
        echo "****************************************************************************"
        echo "        UBUNTU CLIENT CONFIGURATION CAN NOT BE RUN AT THIS TIME :(          "
        echo "Please pre-stage this system in Active Directory, with the desired hostname"
        echo "****************************************************************************"; return;;
  * ) echo "invalid"; return;;
esac
echo " **********************************************************************************"
echo " **********************************************************************************"
##Send to log file
echo $(date) ${filename} SUCCESS: $(hostname) prestaged in active directory >> /var/log/fse.log

##########################################################################################
#############################        Join FULTON.AD.ASU.EDU.           ###################
##########################################################################################
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************               JOIN TO ACTIVE DIRECTORY          ********************"
echo " **********************************************************************************"
echo " "
echo "Please enter your Fulton AD Domain Credentials in order to bind this computer to fulton.ad.asu.edu"
domainjoin-cli join fulton.ad.asu.edu 
#Send to log file
echo $(date) ${filename} SUCCESS: $(hostname)successfully joined to fulton.ad.asu.edu >> /var/log/fse.log

##########################################################################################
#############################       Configure Login PBIS-OPEN          ###################
##########################################################################################

/opt/pbis/bin/config UserDomainPrefix ASUAD
/opt/pbis/bin/config AssumeDefaultDomain true 
/opt/pbis/bin/config LoginShellTemplate /bin/bash 
#/opt/pbis/bin/config HomeDirTemplate %H/%U 
#/opt/pbis/bin/config RequireMembershipOf 

#Send to log file
echo $(date) ${filename} SUCCESS: PBIS-Open Client Configuration >> /var/log/fse.log

##########################################################################################

##########################################################################################
##########################################################################################
##########################################################################################
echo "***********************************************************************************"
echo "*************           REGISTERING WITH LANDSCAPE           **********************"
echo "*************           landscape.fulton.ad.asu.edu          **********************"
echo "***********************************************************************************"


##########################################################################################
##########################################################################################
##########################  Request Client registration from Landscape  ##################
##########################################################################################
##########################################################################################

echo “Beginning Landscape Configuration”
landscape-config --computer-title $(hostname -f) --script-users nobody,landscape,root --silent

#Send to log file
echo $(date) ${filename} SUCCESS: FSE Landscape Registration Complete >> /var/log/fse.log

##########################################################################################
###########################             Reset Login Screen               #################
##########################################################################################

cp /install/fse/login/firstlogin/lightdm.conf /etc/lightdm/
chown root:root /etc/lightdm/lightdm.conf
chmod a+x /etc/lightdm/lightdm.conf

#Send to log file
echo $(date) ${filename} SUCCESS: Final Login Screen Configured >> /var/log/fse.log

##########################################################################################
######## 18.04 Systems Only
##########################################################################################
#this file will remove autologin

#the lbs-release file has information on the Ubuntu version
#the first grep returns the line containing the version number
#the second grep determins if it 18.04

#ver_chk=$(cat /etc/lsb-release | grep RELEASE | grep -q 18.04)

# ver_chk will return as a 0 if the grep is matched
# If no match, it will return a 1

#if ${ver_chk};
#then
#       
#else
#        rm /etc/gdm3/custom.conf
#        mv /etc/gdm3/custom.conf.bak /etc/gdm3/custom.conf
#fi

##########################################################################################
#######################              CLIENT PATCHING                ######################
##########################################################################################

#Avahi-Daemon Patching
#cp /install/fse/patch/avahi/avahi-daemon.conf /etc/avahi/
#echo $(date) ${filename} SUCCESS: Avahi-Daemon patching completed >> /var/log/fse.log

##########################################################################################
######################            MOUNT SOURCE FILESHARE	         #####################
##########################################################################################

#echo “Installing CIFS-UTILS”
#apt-get install cifs-utils -y

#echo “Making New Source Directory”
#mkdir /mnt/source/

#echo “Mounting CIDSE-FS-01”
#mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!
#/
##########################################################################################

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

#echo “Copying CIDSE 2018 Wallpaper”
#rm /usr/share/backgrounds/warty-final-ubuntu.png
#cp /mnt/source/linux/ubuntu/config/cidse/workstation/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/
#chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
#chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png


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
#
echo "provisioning.sh complete"

#sleep 10
#reboot


