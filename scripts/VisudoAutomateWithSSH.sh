#### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
echo 'Enter Techs password When Prompted'
ssh -t $HOST '


#### Run Commands ####

#get the groupname 
echo "enter groupname without prefix"
read Group
Group="%FULTON\\\\\\"$Group"	ALL=(ALL:ALL) ALL"
#add to the sudo file
echo $Group | sudo tee -a /etc/sudoers'
