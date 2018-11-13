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


##########################################################################################
##########################################################################################
#############################       Add CIDSE IT to SUDO             ###################
##########################################################################################
# Check if user is in root
if [[ $EUID -ne 0 ]]; then
echo "Please run in root"
exit
fi
CidseItGroup="%FULTON\\\cidse-it    ALL=(ALL:ALL) ALL"
cat /etc/sudoers > /etc/sudoers.tmp
echo "$CidseItGroup" >> /etc/sudoers.tmp
echo "**********************************************************"
echo "CIDSE IT Group has been added to sudoers"
echo "**********************************************************"
clear
##########################################################################################
##########################################################################################
#############################       Add Lab Admins to SUDO             ###################
##########################################################################################
#
########## Verify Ownership and add proper Security Group to sudo
echo "**********************************************************************************"  
echo ""
echo "                        Who is the owner of this system ?"
echo " "
echo "   (Note: The system "OWNER" is the Faculty member who purchased the device )"
echo ""
echo "**********************************************************************************"  
echo ""
echo "Please enter the owners ASURITE ID (example: adoupe1, jwhite40, lslade):"
read -r owner
echo "**********************************************************************************"             
echo ""
owner="$owner"
Group="%FULTON\\\\\\CIDSE-"$owner"_Lab_Admins    ALL=(ALL:ALL) ALL"
###
echo ""
echo ""
read -p "You have indicated that the owner of this system is $owner? Is this correct? (Y)es/(N)o?" choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "****************************************************************************"
        echo "****************************************************************************"
        echo "****************************************************************************"
        echo "        OWNER CONFIGURATION CAN NOT BE COMPLETED AT THIS TIME :(          "
        echo "    Please verify who owns this system and restart the configuration       "
        echo "****************************************************************************"; return;;
  * ) echo "invalid"; return;;
esac
echo " **********************************************************************************"
echo " **********************************************************************************"

clear
###
### add to the sudo file
echo " Configuring ownership and setting up proper sudoer access"
cat /etc/sudoers > /etc/sudoers.tmp
echo "$Group" >> /etc/sudoers.tmp

###Write to log
echo $(date) ${filename} SUCCESS: Owner set to "$ASURITE" >> /var/log/fse.log
clear
###

echo "Output of sudoers file"
echo "**********************************************************"
cat /etc/sudoers.tmp
echo "**********************************************************"
echo "**********************************************************"
echo
echo 'Do the contents of the sudoers file look correct? [Y/N]?'
read -r answer
echo "**********************************************************"
if [[ $answer = [yY] ]]; then
    cp /etc/sudoers.tmp /etc/sudoers && echo "Device Ownership and SUDOERS have been configured" && rm /etc/sudoers.tmp
else
echo 'Not committing changes. Exiting Now'
fi











