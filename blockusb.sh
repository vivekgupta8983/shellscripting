#!/bin/bash

## block usb storage in Linux System
# Check if running as root  
 
 if [ "$(id -u)" != "0" ]; then  
   echo "This script must be run as root" 1>&2  
   exit 1  
 fi 


lsmod | grep usb_storage
modprobe -r usb_storage
modprobe -r uas
lsmod | grep usb

cd /lib/modules/`uname -r`/kernel/drivers/usb/storage/
mv usb-storage.ko usb-storage.ko.blacklist
