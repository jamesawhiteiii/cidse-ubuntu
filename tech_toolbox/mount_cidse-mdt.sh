

#!/bin/bash

####Mount cidse-fs-01 ####

echo “Installing CIFS-UTILS”
apt-get install cifs-utils -y

echo “Making New Source Directory”
mkdir /mnt/MDT/

echo “Mounting CIDSE-FS-01”
mount.cifs //cidse-mdt.fulton.ad.asu.edu/DeploymentShare /mnt/MDT -o vers=3.0,username=jwhite40ad,domain=FULTON

####################################################


