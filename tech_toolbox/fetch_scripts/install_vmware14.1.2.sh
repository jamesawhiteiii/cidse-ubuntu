#|**********************************************************************;
# Project           : Install Matlab 2018a
#
# Program name      : fetch_matlab2018.sh
#
# Author            : James A. White III
#
# Date created      : Sep 10, 2018
#
# Purpose           : make it easy to make scripts that run on remote systems
#                        1. Enter the commands where it tells you  and save it as a new file.
#                        2. Done
#
#**********************************************************************;
echo "This script will deploy MATLAB R2018a to the intended host system"

#### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
echo 'Please enter Techs password When Prompted'
ssh -t $HOST '

##########################################################################
# REMOTE COMMANDS
##########################################################################


##########################################################################
# Change to /tmp
##########################################################################
cd /tmp
##########################################################################
# DOWNLOAD LIVE INSTALLER FILE FORM GITHUB REPO
##########################################################################

wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/software/vmware14.1.2.sh

##########################################################################
# SET PERMISSIONS
##########################################################################

chmod u+x /tmp/vmware14.1.2.sh

##########################################################################
# RUN LIVE INSTALLER
##########################################################################

bash /tmp/install_vmware14.1.2.sh --verbose
'
