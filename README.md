# fse-ubuntu

This repository contains the various files involved in creating an automatic Ubuntu installation suited for the
FSE environment. Copying the respective files in this repository to their prescribed locations on an Ubuntu installation
USB or ISO will allow you to create an automatic installation. 


#### Getting around this repository

Each top level folder houses different scripts or other resources, below is a helpful guide to know where to look

- deploy/ -- Base OS installation automation (Preseed, grub.cfg, firstboot.sh)
- provisioning/ -- Ubuntu basic configuration (firstboot_live and firstlogin_live scripts, backgrounds)
- scripts/ -- Utilities for FSE IT staff to run
- software/ -- Software for FSE IT staff to install

## Getting Started

The easiest way to get started is using these files is by placing them on an already created Ubuntu installation USB drive.
It is recommended you create your USB drive with Rufus or a similar utility that leaves R/W access to the drive when complete.
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

| Step          | Description                                     | Key Action                       |
| ------------- | ----------------------------------------------- | -------------------------------- |
| Boot from USB | Display FSE Preseed options via custom grub.cfg | Automated OS install             |
| First bootup  | Run .firstboot.sh, run firstboot_live.sh        | Wget firstboot_live.sh and firstlogin_live.sh   |
| First login   | Run .firstlogin_live.sh                         | Final provisioning steps         |


Should you encounter errors during the process, always check the logs first at /var/log/fse.log.
All the above steps are setup to write to that log file at various stages of the process. Both firstboot
and firstlogin scripts can be run again simply by restarting the computer if they did not complete successfully.
So don't worry if you cancel them or run into an error (such as no network). Simply restart and the script
will launch again.


## Files and Brief Descriptions


Files, their descriptions and purpose are listed below in the order they occur during the process. All parts of the process write logs to /var/log/fse.log.


#### /deploy/preseed/fse-*.seed files

These are the preseed files themselves. They represent the answers to the questions usually presented by the GUI
installer. Things such as partitioning, user creation, third-party packages, and timezone are all set in the preseed
file. Upon completion the preseed sets up log files at /var/log/fse.log.


#### /deploy/preseed/.firstboot.sh
This script is set to run after the installation restarts the computer. It runs noninteractively before login.
It will place logs in /var/log/fse.log. Its purpose is currently to: 
- Check for internet connectivity
- WGET and run the firstboot_live.sh

#### /provisioning/firstboot_live.sh

This script runs after it downloaded by firstboot.sh. It runs noninteractively before login. Its purpose is currently to: 

- Setup techs autologin
- Install and prepare the Landscape client
- Install openssh-server
- Copy firstlogin.sh and set it to autostart on login
- Set the FSE pitchfork/provisioning background
- WGET and setup firstlogin_live.sh
- Reload the GUI to initiate the autologin
- Remove itself and its autostart

#### /provisioning/firstlogin_live.sh

This script will run interactively on every login until it is removed. Its purpose is currently to:

- Set the pitchfork/provisioning background for 18.04+
- Set the hostname
- Register to Landscape
- Disable autologin and configure login screen
- Remove firstlogin_live.sh
- Reload GUI to complete the process

## Other Files of Note

Other key files that aren't directly involved in the provisioning process and their purpose.

#### /deploy/preseed/install/fse/fse_env

This file contains the text string of the Git branch you want to pull files from. This would allow you to change a USB drive to pull files from either a dev or testing branch versus the live 'master' production branch. All the scripts listed above will look to this file to make a decision on where to wget live files from.