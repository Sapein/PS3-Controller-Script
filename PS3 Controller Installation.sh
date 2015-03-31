#!/bin/bash

#This is a simple script to install the required drivers to use a PS3 controller on Debian 7.8 "Wheezy".

#This simply makes the "logMode" and Output file, this is used to make sure that everything is working, plus it's easier to change to /dev/null if needed
logMode=~/Output.txt
echo "This is to make Output.txt" > Output.txt

clear #This just makes sure that the screen is cleared for this, to prevent screen clutter.

#This introduces the script and lets the user know that this is only for Debian Wheezy. It gives the user two chances to cancel, one after 30 seconds, and another with their own input
echo "This script is ONLY for Debian 7.8 "Wheezy" if you are not running this distribution of linux please stop now." 
echo "To do this please hit Control+C now."
echo "Also remember, Sapein/Chanku is not liable to any damages caused to your computer by this script, it is provided as is."
sleep 30 #sleeps for 30 seconds for user input

echo "You have made no attempt to stop the script, however one last chance is to be given, to continue please type y or Y, otherwise the script will terminate."
read cont #This gives the user one last change to 'escape' so to speak, this time waiting for user input.
#this checks to make sure the user hasn't inputted y or Y and then shuts down the script after 30 seconds and clears the screen.
if [ $cont = "y" ] 
then
	if [ $cont = "Y" ]
	then
		echo "The Script has been terminated per user request"
		sleep 30 #sleeps for 30 seconds
		clear
		exit
	fi
fi

#Should they not cancel the script it informs them that the script will continue, and Clears the screen, they also have 30 seconds to cancel it should they choose.
echo "The script will now continue."
echo "Clearing screen"
sleep 30 #Once again sleeps for 30 sconds
clear

#This allows the user to know what is going on without giving them too much information, also for debugging purposes the output of the file is redirected to logMode.
echo "Installing dependencies"
echo ""
echo "Installing bluetooth drivers...."
sudo apt-get -qq --force-yes install bluetooth >> logMode #installs the base bluetooth drivers 
echo "Done!"
echo ""
echo "Installing extra BlueZ utilities..."
sudo apt-get -qq --force-yes install bluez-firmware bluez-utils bluez-tools bluez-hcidump bluez-compat >> logMode 2>&1 #installs extra libraries that may be needed
echo "Done!"
echo ""
echo "Installing extra bluetooth dependecies..."
sudo apt-get -qq --force-yes install libbluetooth-dev >> logMode 2>&1 #installs the extra bluetooth libraries
echo "Done!"
echo ""
echo "Installing all other dependencies..."
sudo apt-get -qq --force-yes install build-essential checkinstall libusb-0.1-4 pkg-config libusb-dev joystick >> logMode 2>&1 #installs most of the other needed dependcies
sudo apt-get -qq --force-yes install usbutils >> logMode 2>&1 #installs usbutils incase it isn't already installed
echo "Done!"
echo ""

#This asks if your bluetooth device is made my Atheros, which requires it's own firmware library, this way I don't install this un-necessary firmware
echo "Is your bluetooth device made by Atheros? If so, or if you do not know then please enter y or Y otherwise you may skip this."
read isAtheros

#It merely installs the firmware and then asks the user to re-insert the device to allow it to load the firmware for it.
if [ $isAtheros = "y" ]
	echo "Installing Atheros Firmware..."
	sudo apt-get -qq --force-yes install firmware-atheros >> logMode 2>&1
	echo "Done!"
	echo "Please re-insert your device, and press y  once you are done."
	isFinished=0	
	while [ $isFinished -eq 0 ]
	do
		read userInput
		if [ userInput = "y" ]
		then
			isFinished=1
		fi
	done
elif [ $isAtheros -eq "Y" ]
then
	echo "Installing Atheros Firmware"
	sudo apt-get -qq --force-yes install firmware-atheros >> logMode
	echo "Done!"
	echo "Please re-instert your bluetooth device and press y once you are done."
	isFinished=0	
	while [ $isFinished -eq 0 ]
	do
		read userInput
		if [ userInput = "y" ]
		then
			isFinished=1
		fi
	done
fi

#Begins the second phase, or the setup/compilation phase.
echo "Now beggining second phase of installation..."
echo "Clearing screen"
sleep 30 
clear

#This is the download/compilation step, with all dependencies installed it downloads the required libraries
echo "Downloading the latest version of SixPair..."
mkdir ~/.PS3Controller
mkdir ~/.PS3Controller/SixPair
#This downloads the SixPair file from the link and stores it in the correct directory, and puts all output in logMode
wget -P ~/.PS3Controller/SixPair http://www.pabr.org/sixlinux/sixpair.c >> logMode 2>&1
echo "Done!"
echo ""
echo "Downloading the latest version of SixAd."
wget -P ~/.PS3Controller https://github.com/falkTX/qtsixa/archive/master.zip >> logMode 2>&1
echo "Done!"
echo "Now Unzipping"

#This unzips the qtsixa files into the correct directory and then removes the zip file.
mkdir ~/.PS3Controller/qtsixa-master
unzip -oq ~/.PS3Controller/master.zip -d ~/.PS3Controller/qtsixa-master
rm -rf ~/.PS3Controller/master.zip

#Compiles sixpair.c and stores it's output in logMode along with using make on sixad
echo "Now Compiling..."
gcc -o ~/.PS3Controller/SixPair/sixpair ~/.PS3Controller/SixPair/sixpair.c -lusb >> logMode 2>&1
make -C ~/.PS3Controller/qtsixa-master/sixad >> logMode 2>&1
sudo mkdir -p /var/lib/sixad/profiles #makes sixad's profile directory

#This makes the package step, the user MAY have to input something so it lets them know that they may have too
echo "Please note for the next step you may have to manually something."
cd ~/.PS3Controller/qtsixad-master
sleep 10 #A ten-second sleep to let the user read the message.
sudo checkinstall -y 

#Now begins the setup step.
echo "The Installation is now done...please plug in your PS3-Controller via USB at this time..."
echo "This script will verify if it is plugged in..."
sleep 30 #This waits 30 seconds for the user to plug in the PS3-Controller before reporting the status
ext=0
while [ $ext -eq 0 ]
do 
	echo "Checking to see if you have the controller plugged in..." #tells the user what it is doing.
	sleep 10 #gives the user ten seconds
	if lsusb | grep -qi sony; then 
		if lsusb | grep -qi PlayStation; then
			#tells the user that it was found and that the script is continuing
			echo "Controller found..." 
			echo "Continuing..."
			ext=1
		else
			echo "Controller not detected, please make sure it is a SONY PS3 Controller and make sure it is plugged in via USB."
			sleep 10
		fi
	else
			echo "Controller not detected, please make sure it is a SONY PS3 Controller and make sure it is plugged in via USB."
			sleep 10 #waits 10 seconds before rechecking to prevent screen spamming
	
done

echo "Now paring the PS3 Controller to the Bluetooth USB device."
#changes working directory to SixPair and runs the ./sixpair command.
cd ~/.PS3Controller/SixPair
sudo ./sixpair

#This is the final set-up step allowing users to connect their PS3 controller 
echo "Done! Please disconnect your PS3 Controller now."
sleep 30 
echo "running sixad. pleaes follow the directions on screen." 
echo "This script is finished in order to start sixad outside of this script, just do sixad --start"
echo "More information for sixad can be found in the manual"
sudo sixad --start #starts sixad