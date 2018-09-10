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
#######################  STARTING MATLAB 2017a INSTALLER #######################
################################################################################

echo “Running MATLAB INSTALLER”
sh /mnt/source/Apps/Mathworks/Matlab/Linux/2017a/install -inputFile /mnt/source/Apps/Mathworks/Matlab/Linux/2017a/installer_input.txt

echo “Creating Symbolic Links for Easy Launch”
ln -s /opt/Matlab/Ra/bin/matlab /usr/local/bin/matlab

################################################################################
#######################.         Make CIDSE IT            ######################
################################################################################
mkdir /cidseit


################################################################################
#######################.  Matlab Installer confirmation   ######################
################################################################################


chown -R techs /cidseit/
touch /cidseit/matlab2017a.sh



