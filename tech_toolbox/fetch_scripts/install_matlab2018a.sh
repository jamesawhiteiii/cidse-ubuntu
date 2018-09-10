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
##########################################################################

echo "This script will deploy MATLAB R2018a to the intended host system."
echo "    Please enter the hostname you would like to deploy MALTLAB "

#### Get Host Name ####
echo '(enter hostname in "enXXXXXXXl" format)'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
ssh -t $HOST '
echo 'Please enter Techs password When Prompted'

##########################################################################
# REMOTE COMMANDS
##########################################################################


##########################################################################
# CHANGE TO /TMP
##########################################################################

cd /tmp/


##########################################################################
# DOWNLOAD LIVE INSTALLER FILE FORM GITHUB REPO
##########################################################################

wget https://raw.githubusercontent.com/jamesawhiteiii/cidse-ubuntu/master/software/matlab2018a.sh


##########################################################################
# SET PERMISSIONS
##########################################################################

chmod u+x /tmp/matlab2018a.sh

##########################################################################
# RUN LIVE INSTALLER
##########################################################################

bash /tmp/matlab2018a.sh --verbose
'
