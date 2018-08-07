#!/bin/bash

####Mount cidse-fs-01 ####

echo “Installing CIFS-UTILS”
apt-get install cifs-utils -y

echo “Making New Source Directory”
mkdir /mnt/source/

echo “Mounting CIDSE-FS-01”
mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!

################################################################################
################################################################################
################################ COPY WINDOWS 10 VM      #######################
################################################################################


################################################################################
##################  Change to VMWare Workstation Directory  ####################
################################################################################
echo “Copying Windows VM files to Local System”
cp -R /mnt/source/Images/VMware/Win10/Win10x64v1607/ /var/lib/vmware/Shared\ VMs


################################################################################
#######################           Make CIDSE IT           ######################
################################################################################

################################################################################
#######################      Installer confirmation.      ######################
################################################################################


chown -R techs /cidseit/
touch /CIDSEIT/Windows10VM.txt



