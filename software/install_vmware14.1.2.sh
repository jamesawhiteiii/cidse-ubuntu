#!/bin/bash

####Mount cidse-fs-01 ####

echo “Installing CIFS-UTILS”
apt-get install cifs-utils -y

echo “Making New Source Directory”
mkdir /mnt/source/

echo “Mounting CIDSE-FS-01”
mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!
#mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=$1$dJM1gWg9$JnMr8yIJtL1.VRRmhwxrv1
################################################################################
################################################################################
#####################     INSTALL VMWARE WORKSTATION     #######################
################################################################################

sh /mnt/source/Apps/VMware/Workstation/Linux/14/VMware-Workstation-Full-14.1.2-8497320.x86_64.bundle --console --required --eulas-agreed --set-setting vmware-workstation serialNumber N148H-J124N-581DE-03AH2-1DZ4J
apt-get update
apt-get install open-vm-tools-desktop -y

################################################################################
#######################   Matlab Installer confirmation   ######################
################################################################################

#touch /cidseit/softwarevmware14.sh
