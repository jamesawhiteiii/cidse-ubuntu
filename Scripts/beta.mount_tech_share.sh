#!/bin/bash


################################################################################################
################################################################################################
################################################################################################
#			                   NEW WORKSTATION PROVISIONING
################################################################################################
#				                       version 1.0
################################################################################################
#				                 created by: James White
#				                       	CIDSE
#				                 Arizona State University
#				                last updated Aug 1, 2017
################################################################################################
################################################################################################


################################################################################################
#################################   Mount Source Share  ########################################
################################################################################################

echo “Installing CIFS-UTILS”
apt-get install cifs-utils -y

echo “Making New Source Directory”
mkdir /mnt/Deploy/

echo “Mounting CIDSE-STORAGE”


echo “Mounting CIDSE-FS-01”
mount.cifs //cidse-storage.fulton.ad.asu.edu/Deploy /mnt/Deploy -o vers=3.0,username=fetch,domain=cidse-storage,password=$1$Rlb5dudh$pdD4zrrDWEg7oaqZPX08i/

#mount.cifs //cidse-storage.fulton.ad.asu.edu/Deploy /mnt/Deploy -o vers=3.0,username=fetch,domain=cidse-storage,password=!QAZ2wsx$RFV5tgb


