#!/bin/bash

## block usb storage in Linux System
# Check if running as root  
 
 if [ "$(id -u)" != "0" ]; then  
   echo "This script must be run as root" 1>&2  
   exit 1  
 fi 


sudo lsmod | grep usb_storage
sudo modprobe -r usb_storage
sudo modprobe -r uas
sudo lsmod | grep usb

cd /lib/modules/`uname -r`/kernel/drivers/usb/storage/
sudo mv usb-storage.ko usb-storage.ko.blacklist
