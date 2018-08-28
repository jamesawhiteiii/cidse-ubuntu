# fse-ubuntu

This repository contains the various files involved in creating an automatic Ubuntu installation suited for the
FSE environment. Copying the respective files in this repository to their prescribed locations on an Ubuntu installation
USB or ISO will allow you to create an automatic installation. 

## Getting Started

The easiest way to get started is using these files is by placing them on an already created Ubuntu installation USB drive.
Modifying and recreating an ISO is a more involved process and covered in a different document.

### Prerequisites

Ubuntu 14.04 USB/ISO
or
Ubuntu 16.04 USB/ISO
or 
Ubuntu 18.04 USB/ISO

### Installing

To set up a flash drive to utilize the preseed there a few files that should be copied or modified.
The following process will create an EFI supported installation but will not add legacy boot or installation
support. The USB or ISO will only be able to perform EFI installations.


Copy the /preseed directory to */USBorISO/preseed/*
(contains fse-sata.seed, fse-nvme.seed, fse-satanoencrypt.seed, fse-nvmenoencrypt .firstboot.sh, and install directory to */USBorISO/preseed/*


Copy the grub.cfg to */USBorISO/boot/grub/* (you may want to backup the current copy)


After this you should be able to boot from the ISO or USB and be presented with a screen with
the new automated preseed options showing up alongside the usual options such as 'Try Ubuntu' or 'Install Ubuntu'. Note, once
you launch one of these options the installation will begin, no additional prompts will be shown. This includes wiping the 
first hard drive of any existing data. Before you launch a preseeded boot option ensure you have a backup of any data.


At a high level the process is:

1. Boot machine, load the menu options from grub.cfg
2. Install OS based on selected option and respective preseed file
3. Restart after install completes
4. Run firstboot.sh silently
5. Autologin and run firstlogin.sh interactively


Should you encounter errors during the process, always check the logs first at /var/log/fse.log.
All the above steps are setup to write to that log file at various stages of the process. Both firstboot
and firstlogin scripts can be run again simply by restarting the computer if they did not complete successfully.
So don't worry if you cancel them or run into an error (such as no network). Simply restart and the script
will launch again.


## Files and Brief Descriptions


#### fse.seed and fse-nvme.seed

These are the preseed files themselves. They represent the answers to the questions usually presented by the GUI
installer. Things such as partitioning, user creation, third-party packages, and timezone are all set in the preseed
file. These two files contain all the same answers however one targets the first SATA device, and one targets the first NVMe
device. Upon completion the preseed sets up log files at /var/log/fse.log.

#### firstboot.sh

This script is set to run after the installation restarts the computer. It runs noninteractively before login.
It will place logs in /var/log/fse.log. Its purpose is currently to: 

- Verify network connectivity before proceeding (will exit without it)
- Patch avahi (prevents error message on login)
- Copy the local admin (techs) user profile
- Copy the Landscape client files
- Setup the PBIS repository (PBIS is for binding to Active Directory)
- Perform an apt-get update and apt-get upgrade
- Install openssh-server, landscape-client, pbis-open
- Setup lightdm to autologin to the techs account
- Set up the firstlogin.sh script
- Change the background to the pitchfork
- Restart lightdm which will then autologin
- Remove itself if the above steps succeed

#### firstlogin.sh

This script will run interactively on every login until it is removed. Successful completion of all its steps
will lead to the script removing itself. Its purpose is currently to:

- Verify network connectivity before proceeding (will exit without it)
- Prompt for techs sudo password
- Prompt for machine hostname
- Prompt for Fulton credentials to bind to Active Directory
- Attempt to join the Landscape server
- Remove itself and disable autologin if the above steps succeed


#### install Folder

Contains various resources for the installation process:

- Pitchfork background
- Landscape client files
- Lightdm.conf (for techs autologin)
- Techs profile/home directory
- firstlogin.sh script file
