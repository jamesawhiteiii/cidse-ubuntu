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
clear
##########################################################################################
echo " *****************************************************************************"
echo " *****************************************************************************"
echo " *********              FSE UBUNTU CLIENT SETUP             ******************"
echo " ********************************************************************************"
##########################################################################################
#################################     SET HOSTNAME      ##################################
##########################################################################################
echo " *****************************************************************************"
echo " *********                   SET HOSTNAME                   ******************"
echo " *****************************************************************************"
### Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)
### Display existing hostname
echo "The current hostname of this systems is $hostn"
### Ask for new hostname $newhost
echo " *****************************************************************************"
echo " *****************************************************************************"
echo " "
echo " Please enter the desired hostname for this system: "
read newhost
echo " *****************************************************************************"
echo " *****************************************************************************"
#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhost/g" /etc/hosts
sed -i "s/$hostn/$newhost/g" /etc/hostname
service hostname start
echo " **********************************************************************************"
echo " **********************************************************************************"
clear
echo " **********************************************************************************"
echo " **********************************************************************************"
echo "Please wait...setting the hostname of this system to $newhost..."
echo 
sleep 5
echo " **********************************************************************************"
echo " **********************************************************************************"
hostname $newhost
echo " Hostname has been updated to:
hostname
echo " **********************************************************************************"
### Write out to log
echo $(date) ${filename} SUCCESS: Hostname is $newhost >>/var/log/fse.log
clear
#
##########################################################################################
####################                   CONFIGURE                  ########################
####################                 ACTIVE DIRECTORY             ########################
##########################################################################################
##########################################################################################
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************                 **WARNING**                   **********************"
echo " **********************************************************************************"
echo " *************      ALL NEW SYSTEMS MUST BE PRE-STAGED       **********************"
echo " *************         WITHIN ACTIVE DIRECTORY               **********************"
echo " **********************************************************************************"
echo " *************         PLEASE VERIFY THAT THE DEVICE         **********************"
echo " *************    IS IN THE PROPER OU BEFORE PROCEEDING      **********************"
echo " **********************************************************************************"

##########################################################################################
##############################    Verify AD PreStage    ##################################
##########################################################################################
#Require the technician to verify whether or not the computer has been prestaged in AD. 
echo " "
echo "  *******************************************************************************"
echo "  ************           Active Directory Pre-Stage             *****************"
echo "  *******************************************************************************"
echo " "
read -p "Has this computer already been pre-staged in Active Directory? (Y)es/(N)o?" choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "*************************************************************************"
        echo "*************************************************************************"
        echo "*************************************************************************"
        echo "       UBUNTU CLIENT CONFIGURATION CAN NOT BE RUN AT THIS TIME :(          "
        echo "Please pre-stage this system in Active Directory, with the desired hostname"
        echo "****************************************************************************"; return;;
  * ) echo "invalid"; return;;
esac
echo " **********************************************************************************"
echo " **********************************************************************************"

clear
##########################################################################################
#############################        Join FULTON.AD.ASU.EDU.           ###################
##########################################################################################
echo " ********************************************************************************"
echo " *************            JOINING TO ACTIVE DIRECTORY          ******************"
echo " ********************************************************************************"
echo " "
echo "Please enter your Fulton AD Domain Credentials in order to bind this computer to Active Directory"
echo "     This is your AD account (example: jwhite40ad)                               "
domainjoin-cli join fulton.ad.asu.edu 
#
#Send to log file
echo $(date) ${filename} SUCCESS: $(hostname)successfully joined to fulton.ad.asu.edu >> /var/log/fse.log
clear
##########################################################################################
##########################################################################################
#############################         Add CIDSE IT to SUDO             ###################
##########################################################################################
echo " ********************************************************************************"
echo " *************             Adding CIDSE IT to SUDO...          ******************"
echo " ********************************************************************************"
echo " "
### Adding CIDSE-IT Security Group to /etc/sudoers
CidseItGroup="%FULTON\\\cidse-it    ALL=(ALL:ALL) ALL"
cat /etc/sudoers > /etc/sudoers.tmp
echo "$CidseItGroup" >> /etc/sudoers.tmp
### Write to log
echo $(date) ${filename} SUCCESS: %FULTON\\\cidse-it add to sudoers >> /var/log/fse.log
echo "           **********************************************************"
echo "           #       The CIDSE IT Group has been added to sudoers .   #"
echo "           **********************************************************"
clear
##########################################################################################
##########################################################################################
#############################       Add Lab Admins to SUDO             ###################
##########################################################################################
echo " ********************************************************************************"
echo " *************        Adding Owner's Lab Admins to sudo...     ******************"
echo " ********************************************************************************"
echo " "
###   Verify Ownership and add proper Security Group to sudo
echo "*********************************************************************************"  
echo ""
echo "                        Who is the owner of this system?"
echo " "
echo "   (Note: The system "OWNER" is the Faculty member who purchased the device )"
echo ""
echo "**********************************************************************************"  
echo ""
echo "Please enter the owners ASURITE ID (example: adoupe1, huanliu, sshirva43):"
read -r owner
echo "**********************************************************************************"             
echo ""
##SetVariables
owner="$owner"
Group="%FULTON\\\\\\CIDSE-"$owner"_Lab_Admins    ALL=(ALL:ALL) ALL"
echo ""
clear
echo " ********************************************************************************"
echo " *************        Adding Owner's Lab Admins to sudo...     ******************"
echo " ********************************************************************************"
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
echo " ********************************************************************************"
echo " *************        CONFIGURING OWNERSHIP and SUDO...        ******************"
echo " ********************************************************************************"
echo " Please wait..."
cat /etc/sudoers > /etc/sudoers.tmp
echo "$Group" >> /etc/sudoers.tmp
cp /etc/sudoers.tmp /etc/sudoers
###Write to log
echo $(date) ${filename} SUCCESS: Owner set to "$ASURITE" >> /var/log/fse.log
clear
###
echo " ********************************************************************************"
echo " *************                  SUDOERS.TMP                    ******************"
echo " ********************************************************************************"
cat /etc/sudoers.tmp
echo "*********************************************************************************"
echo "*********************************************************************************"
echo ""
echo 'Looking at the lines above, has the correct security group been added to the sudoers file? [Y/N]?'
read -r answer
echo "*********************************************************************************"
if [[ $answer = [yY] ]]; then
    cp /etc/sudoers.tmp /etc/sudoers && echo "Device Ownership and SUDOERS have been configured" && rm /etc/sudoers.tmp
    echo $(date) ${filename} SUCCESS: Device Ownership $owner and SUDOERS have been configured >> /var/log/fse.log
else
echo 'Not committing changes. Exiting Now'
fi

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

clear
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
mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!
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

################################################################################
#######################  STARTING MATLAB 2018a INSTALLER #######################
################################################################################

#echo “Running MATLAB 2018a INSTALLER”
#sh /mnt/source/Apps/Mathworks/Matlab/Linux/2018a/install -inputFile /mnt/source/Apps/Mathworks/Matlab/Linux/2018a/installer_input.txt

#echo “Creating Symbolic Links for Easy Launch”
#ln -s /opt/Matlab/R2018a/bin/matlab /usr/local/bin/matlab

################################################################################
#######################  STARTING VMWARE 14.1.2 Install  #######################
################################################################################
#echo "Installing VMWARE 14 with Windows 10 VM"
#sh /mnt/source/linux/ubuntu/software/common/vmware/14/install_vmware14.0.0.sh
#sh /mnt/source/Apps/VMware/Workstation/Linux/14/VMware-Workstation-Full-14.1.2-8497320.x86_64.bundle --console --required --eulas-agreed --set-setting vmware-workstation serialNumber N148H-J124N-581DE-03AH2-1DZ4J
#apt-get update
#apt-get install open-vm-tools-desktop -y

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
echo "copying Default Techs Profile"
rm -r /home/techs/
cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/techs/ /home/
chown -R techs /home/techs/


##########################################################################################
############################   COPY DEFAULT USER PROFILE  ################################
##########################################################################################

#cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/default/. /etc/skel; \


##########################################################################################
##############    Copy the Fulton background to the default location and file   ##########
##########################################################################################

echo “Setting CIDSE 2018 Wallpaper”
cd /usr/share/backgrounds 
rm /usr/share/backgrounds/warty-final-ubuntu.png
wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/provisioning/background/warty-final-ubuntu.png
chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png


##########################################################################################
############################   Set Login Configuration     ###############################
# Lightdm.conf file is set to allow TECHS to auto login
echo “Copying Lightdm.conf”
cd /etc/lightdm/
rm /etc/lightdm/lightdm.conf
wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/provisioning/lightdm.conf
chown root:root /etc/lightdm/lightdm.conf
chmod a+x /etc/lightdm/lightdm.conf

#################################################################################################
#################################################################################################
###############################                 CLEAN UP                #########################
#################################################################################################
#################################################################################################
rm /home/techs/.config/autostart/provisioning.desktop
rm /etc/rc.local

#mkdir /var/log/fse/cidse
#touch /var/log/fse/cidse/workstation_config.txt
#
echo "provisioning.sh complete"

sleep 30
#reboot


