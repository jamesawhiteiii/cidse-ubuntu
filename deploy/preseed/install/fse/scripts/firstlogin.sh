#!/bin/bash -i
#
# Author:         James White & Jon Anderson
# Name:           firstlogin.sh
# Purpose:        FSE Ubuntu Client Configuration- First Login Script
# Notes:          Check /var/log/fse.log if you encounter any errors


#####################################################################
# Display some information                                          #
#####################################################################

# Get the filename for logging
filename=$(echo $0 | rev | cut -d'/' -f1 | rev)

echo
echo "Beginning FSE Ubuntu configuration script" ${filename}
echo "Logs are located at /var/log/fse.log"

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



#####################################################################
# Check for root privileges                                         #
#####################################################################
if [ "$(id -u)" != "0" ]
then
echo "This script must be run with root privileges"
echo $(date) ${filename} ERROR: Unable to continue without root privileges, log out and back in to restart the setup process >> /var/log/fse.log
exit 1
fi

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
read -p "Proceed with change? [y|n]: " user_choice

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


##########################################################################################
##########################################################################################
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
#Require the technician to verify whether or not the computer has been prestaged in AD.  #
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
#
##########################################################################################
#############################        Join FULTON.AD.ASU.EDU.           ###################
##########################################################################################
#
echo "Joining this machine to Active Directory"
domainjoin-cli join fulton.ad.asu.edu 
echo $(date) ${filename} SUCCESS: $(hostname)successfully joined to fulton.ad.asu.edu >> /var/log/fse.log

##########################################################################################
#############################       Configure Login PBIS-OPEN          ###################
##########################################################################################

/opt/pbis/bin/config UserDomainPrefix ASUAD
/opt/pbis/bin/config AssumeDefaultDomain true 
/opt/pbis/bin/config LoginShellTemplate /bin/bash 
#/opt/pbis/bin/config HomeDirTemplate %H/%U 
#/opt/pbis/bin/config RequireMembershipOf 
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
echo $(date) ${filename} SUCCESS: FSE Landscape Registration Complete >> /var/log/fse.log

##########################################################################################
###########################             Reset Login Screen               #################
##########################################################################################

cp /install/fse/login/firstlogin/lightdm.conf /etc/lightdm/
chown root:root /etc/lightdm/lightdm.conf
chmod a+x /etc/lightdm/lightdm.conf
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
##########################################################################################
##########################################################################################
echo "***********************************************************************************"
echo "*************        FSE CLIENT CONFIGURATION COMPLETE         ********************"
echo "*************           landscape.fulton.ad.asu.edu          **********************"
echo "***********************************************************************************"
##########################################################################################
##################################  Write Out to Log     #################################
##########################################################################################
echo $(date) ${filename} SUCCESS: FSE Client Configuration Complete >> /var/log/fse.log

##########################################################################################
########################    GET CIDSE BASE CONFIGURATION       ###########################
##########################################################################################
echo $(date) ${filename} Beginning Department Specific Provisioning >> /var/log/fse.log
#
cd /tmp
wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/provisioning/provisioning.sh
chmod u+x /tmp/provisioning.sh
sudo bash /tmp/provisioning.sh --verbose
#
echo $(date) ${filename} SUCCESS: Department Specific Provisioning Complete >> /var/log/fse.log

echo "***********************************************************************************"
echo "*************        CIDSE CLIENT CONFIGURATION COMPLETE        *******************"***********************************************************************************"
echo "***********************************************************************************"

echo "***********************************************************************************"
echo "****          An email has been sent to your Systems Administrator!            ****"
echo "***********************************************************************************"
##########################################################################################





