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
#################################     SET HOSTNAME      ##################################
##########################################################################################
echo " **********************************************************************************"
echo " *************               HOST CONFIGURATION                ********************"
echo " **********************************************************************************"
#### Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)
#### Display existing hostname
#echo "The current hostname of this systems is $hostn"
#### Ask for new hostname $newhost
echo " ******************************************************************************"
echo " ******************************************************************************"
echo " Please specify the new hostname followed by [ENTER]:: "
echo "             (Proper format is en0001234l where 0001234 is the ASU Asset Tag #)"
read -p " " new_hs
read newhost
echo " ******************************************************************************"
echo " ******************************************************************************"
#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhost/g" /etc/hosts
sed -i "s/$hostn/$newhost/g" /etc/hostname
echo " **********************************************************************************"
echo " **********************************************************************************"
#display new hostname
echo "Your new hostname is $newhost"
echo " **********************************************************************************"
echo " **********************************************************************************"

hostname $newhost
##########################################################################################
############################        SET ASU OWNER (ASURITE ID)    ########################
##########################################################################################
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " "
echo "                        Who is the owner of this system ?"
echo " "
echo "   *** (Note: The system "owner" is the Faculty member who purchased the device )***"
echo " "
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " "
read -p "Please enter the owners ASURITE ID, followed by [ENTER]: " fse_owner
echo  "${fse_owner}" >> /etc/fse.owner

#Send to log file
echo $(date) ${filename} SUCCESS: ${fse_owner} owns this system >>/var/log/fse.log

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
read -p " *** Has this computer already been pre-staged in Active Directory? (Y)es/(N)o?  " choice
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

echo “Setting CIDSE 2018 Wallpaper”
cd /usr/share/backgrounds 
rm /usr/share/backgrounds/warty-final-ubuntu.png
wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/blob/master/provisioning/background/warty-final-ubuntu.png
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
#
echo "provisioning.sh complete"

#sleep 10
#reboot


