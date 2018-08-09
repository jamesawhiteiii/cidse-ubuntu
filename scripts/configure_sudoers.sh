#!/bin/bash

# Check if user is in root
if [[ $EUID -ne 0 ]]; then
echo "Please run in root"
exit
fi
################################################################
# get the groupname
echo 'Please enter the name of the lab admins security group'
echo 'The standardd lab admin groupname is: "CIDSE-<professor ASURITEID>_Lab_Admins"'
echo 'Example: CIDSE-adoupe1_Lab_Admins'
read -r Group
Group="%FULTON\\\\\\$Group    ALL=(ALL:ALL) ALL"
CidseItGroup='%FULTON\\\cidse-it    ALL=(ALL:ALL) ALL'
################################################################
# add to the sudo file
cat /etc/sudoers > /etc/sudoers.tmp
echo "$Group" >> /etc/sudoers.tmp
echo "$CidseItGroup" >> /etc/sudoers.tmp
clear
echo 'Output of sudoers file'
echo
cat /etc/sudoers.tmp
echo
echo 'Does the contents of the file look correct? [y/N]'
read -r answer

if [[ $answer = [yY] ]]; then
cp /etc/sudoers.tmp /etc/sudoers
else
echo 'Not commiting changes. Now exiting'
fi
rm /etc/sudoers.tmp
