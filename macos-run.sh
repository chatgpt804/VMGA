#!/bin/bash
# macos-run.sh MAC_USER_PASSWORD VNC_PASSWORD NGROK_AUTH_TOKEN MAC_REALNAME

# disable spotlight indexing
sudo mdutil -i off -a

# Create new account
sudo dscl . -create /Users/thawhakyi
sudo dscl . -create /Users/thawhakyi UserShell /bin/bash
sudo dscl . -create /Users/thawhakyi RealName "$4"
sudo dscl . -create /Users/thawhakyi UniqueID 1001
sudo dscl . -create /Users/thawhakyi PrimaryGroupID 80
sudo dscl . -create /Users/thawhakyi NFSHomeDirectory /Users/koolisw
sudo dscl . -passwd /Users/thawhakyi "$1"
sudo createhomedir -c -u thawhakyi > /dev/null
sudo dscl . -append /Groups/admin GroupMembership thawhakyi

# Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes 

# VNC password
echo "$2" | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' \
 | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Restart VNC service
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# install ngrok
brew install --cask ngrok

# configure ngrok and start tunnel
ngrok config add-authtoken "$3"
nohup ngrok tcp 5900 --log=stdout > ngrok.log &
