#!/bin/bash

#This is a simple removal script to go along with the PS3 Controller Installation Script (Formerly: PS3 Controller Activation Script)
echo "Welcome to the PS3 Controller removal script. This will remove the PS3 Controller files from the Computer, please note that this will not uninstall the bluetooth drivers, as you may still wish to use them."

echo "Do you wish to continue? Press y or Y to continue, otherwise this script will abort."
read cont1

if [ $cont1 ! = "y" ]
then
	if [ $cont1 != "Y" ]
	then
		echo "This script has been terminated per the user's request."
		clear 
		echo "Abort!"
		exit
	fi
fi

echo "Continuing as the user has not terminated the script..."
echo "Clearing screen..."
sleep 10 
clear

if [ ! -d "~/.PS3Controller" ]
then
	echo "The directory used for the installation script is not found, perhaps you meant to install?"
	echo "(Please run the installation script, or download it if you don't have it...)"
	exit
fi

echo "Removing the packages..."
sudo dpkg -r sixad

echo "uninstalling sixad..."
sudo apt-get purge sixad

echo "Removing Folders made by the Installation Script..."
sudo rm -rf ~/.PS3Controller

echo "Cleaning up..."
sudo rm -rf /var/lib/sixad

echo "Done!"
