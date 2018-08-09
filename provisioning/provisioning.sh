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
clear
echo " ********************************************************************************"
echo " ********************************************************************************"
echo " ************              FSE UBUNTU CLIENT SETUP             ******************"
echo " ********************************************************************************"
##########################################################################################
#################################     SET HOSTNAME      ##################################
##########################################################################################

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
#echo "The current hostname of this systems is $hostn"

#Ask for new hostname $newhost

echo " ******************************************************************************"
echo " ******************************************************************************"
echo " "
echo " Please enter the desired hostname for this system: "
read newhost
echo " ******************************************************************************"
echo " ******************************************************************************"
#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhost/g" /etc/hosts
sed -i "s/$hostn/$newhost/g" /etc/hostname
service hostname start
echo " **********************************************************************************"
echo " **********************************************************************************"
#display new hostname
echo "Your new hostname is $newhost"
echo " **********************************************************************************"
echo " **********************************************************************************"
hostname $newhost
clear
##########################################################################################
############################        SET ASU OWNER (ASURITE ID)    ########################
##########################################################################################
echo " *******************************************************************************"
echo " *******************************************************************************"
echo " "
echo "                        Who is the owner of this system ?"
echo " "
echo "   (Note: The system "owner" is the Faculty member who purchased the device )"
echo " *******************************************************************************"
echo " *******************************************************************************"
echo " "
read -p "Please enter the owners ASURITE ID, followed by [ENTER]: " fse_owner
echo  "${fse_owner}" >> /etc/fse.owner
#Send to log file
echo $(date) ${filename} SUCCESS: ${fse_owner} owns this system >>/var/log/fse.log
clear
##########################################################################################
####################                   CONFIGURE                  ########################
####################                 ACTIVE DIRECTORY             ########################
##########################################################################################
##########################################################################################

##########################################################################################
####################     	   CONFIGURE PBIS OPEN            ########################
##########################################################################################

echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************                 **WARNING**                   **********************"
echo " **********************************************************************************"
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
echo " ********************************************************************************"
echo " ********************************************************************************"
echo " ************              Active Directory Pre-Stage          ******************"
echo " ********************************************************************************"
echo " #"
echo " #"
read -p "Has this computer already been pre-staged in Active Directory? (Y)es/(N)o?" choice
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

clear
##########################################################################################
#############################        Join FULTON.AD.ASU.EDU.           ###################
##########################################################################################
echo " ********************************************************************************"
echo " ********************************************************************************"
echo " *************            JOINING TO ACTIVE DIRECTORY          ******************"
echo " ********************************************************************************"
echo " "
echo "Please enter your Fulton AD Domain Credentials in order to bind this computer to Active Directory"
#echo "DOMAIN= FULTON"
domainjoin-cli join fulton.ad.asu.edu 
#
#Send to log file
echo $(date) ${filename} SUCCESS: $(hostname)successfully joined to fulton.ad.asu.edu >> /var/log/fse.log

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

##########################################################################################
##########################################################################################
#############################       Add Lab Admins to SUDO             ###################
##########################################################################################

# Verfiy Ownership and add proper Security Group to sudo
echo "                        Who is the owner of this system ?"
echo " "
echo "   (Note: The system "owner" is the Faculty member who purchased the device )"
echo 'Please enter the ASURITE ID:'
read -r ASURITE
ASURITE="%FULTON\\\\\\CIDSE-$ASURITE_Lab-Admins   ALL=(ALL:ALL) ALL"


#echo 'The standardd lab admin groupname is: "CIDSE-<professor ASURITEID>_Lab_Admins"'
#cho 'Example: CIDSE-adoupe1_Lab_Admins'
#read -r Group
#Group="%FULTON\\\\\\$Group    ALL=(ALL:ALL) ALL"
#CidseItGroup="%FULTON\\\cidse-it    ALL=(ALL:ALL) ALL"
# add to the sudo file
cat /etc/sudoers > /etc/sudoers.tmp
echo "$ASURITE" >> /etc/sudoers.tmp

clear
echo 'Output of sudoers file'
echo
cat /etc/sudoers.tmp
echo
echo 'Does the contents of the file look correct? [y/N]'
read -r answer

if [[ $answer = [yY] ]]; then
cp /etc/sudoers.tmp /etc/sudoers
else
echo 'Not commiting changes. Now exiting'
fi
rm /etc/sudoers.tmp
cd /


##########################################################################################
##########################################################################################
#############################       Configure Sudoers File             ###################
##########################################################################################
#cd /tmp
#wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/scripts/configure_sudoers.sh
#sh /tmp/configure_sudoers.sh

# Check if user is in root
#if [[ $EUID -ne 0 ]]; then
#echo "Please run in root"
#exit
#fi

## get the groupname
#echo 'Please enter the name of the lab admins security group'
#echo 'The standardd lab admin groupname is: "CIDSE-<professor ASURITEID>_Lab_Admins"'
#echo 'Example: CIDSE-adoupe1_Lab_Admins'
#read -r Group
#Group="%FULTON\\\\\\$Group    ALL=(ALL:ALL) ALL"
#CidseItGroup="%FULTON\\\cidse-it    ALL=(ALL:ALL) ALL"

## add to the sudo file
#cat /etc/sudoers > /etc/sudoers.tmp
#echo "$Group" >> /etc/sudoers.tmp
#echo "$CidseItGroup" >> /etc/sudoers.tmp
#clear
#echo 'Output of sudoers file'
#echo
#cat /etc/sudoers.tmp
#echo
#echo 'Does the contents of the file look correct? [y/N]'
#read -r answer

#if [[ $answer = [yY] ]]; then
#cp /etc/sudoers.tmp /etc/sudoers
#else
#echo 'Not commiting changes. Now exiting'
#fi
#rm /etc/sudoers.tmp
#cd /

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


