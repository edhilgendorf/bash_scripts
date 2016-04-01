#!/bin/bash
clear 

#Get userID first
echo $USER >> user.tfr

# declare globals
sPath=""
dPath=""
declare -a d2c=("Desktop" "Documents" "Downloads" "Pictures" "Music" "Movies")
echo "Adminstrator priveleges are required for accessing Volumes at the Root level. Please enter your password"
(( EUID != 0 )) && exec sudo bash -- "$0" "$@"

clear

#set username
uName=$(head -n 1 user.tfr)

echo "Macintosh Data Transfer for $uName
--------------------------------"
echo
echo "Control + C to ABORT at any time"
echo
echo "Press enter to continue..."
read

clear

#Set paths for data transfer here, TBM TO DEST
sPath="/Volumes/Macintosh HD 1/Users/$uName/"
dPath="/Volumes/Macintosh HD/Users/$uName/"

echo "Starting copy"
# Start copy block
for dirName in "${d2c[@]}"; do
    echo "Copying $dirName ..."
    sleep .1
    echo
    rsync -rPvh "$sPath$dirName"/* "$dPath$dirName/"
    sleep 2
    clear
done

echo "Main copy complete, checking for other items in Home..."

diff -q "$sPath" "$dPath" | grep "$sPath" | grep -E "^Only in*" | sed -n 's/[^:]*: //p' > folDiff

clear

for x in "$(cat folDiff)"
    do
        echo "$x found"
        echo "move to destination? (y/n)"
        read moveto
        if [ "$moveto" == "y" ]; then
            echo "Source Path is: $sPath$x"
            echo "Destination Path is: $dPath"
            cp -r  "$sPath$x" "$dPath"
        fi
    done

echo "Checking and fixing permissions for: "
sleep .5
echo $uName
sleep 1
sudo chmod -fR +a "$uName allow read,write,execute,delete,append,readattr,writeattr,readextattr,readsecurity" ~/*
chmod 755 ~/*

echo "Permissions checked and repaired"
sleep .5

echo "Cleaning up..."
rm user.tfr
sleep .3
echo "Process complete... Press enter"
read

