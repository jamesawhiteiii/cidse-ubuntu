
#get the groupname 
echo 'enter groupname without prefix'
read Group
Group="%FULTON\\\\\\"$Group"	ALL=(ALL:ALL) ALL"
#add to the sudo file
echo $Group | sudo tee -a /etc/sudoers
