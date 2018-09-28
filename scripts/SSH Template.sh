|**********************************************************************;
* Project           : SSH Scripts Templates
*
* Program name      : SshTemplates.sh
*
* Author            : William Flemming
*
* Date created      : 06 22 2018
*
* Purpose           : make it easy to make scripts that run on remote systems
*						1. Enter the commands where it tells you  and save it as a new file.
*						2. Done
*
|**********************************************************************;

#### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
echo 'Enter Techs password When Prompted'
ssh -t $HOST '

####enter commands to run in remote system in here####
####ONLY USE DOUBBLE QUOTES IN HERE####

'