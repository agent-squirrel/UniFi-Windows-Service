# UniFi Windows Service
BATCH installer for the UniFi controller as a Windows Service


# Installation
Installing is as easy as running the install.bat file as an administrator.

# Process
1. To begin, the script allows the UniFi controller to talk to it's APs through the Windows Firewall.

2. The script downloads the UniFi controller software from Ubiquiti's website and the JRE 64bit edition from this repo. (The Java site offers no easy way to do this programitcally) and then installs the JRE silently.

3. The UniFi controller is started to generate some needed files and then killed.

4. The UniFi service is installed and all shortcuts to the old controller are removed and replaced with web links to localhost:8443.

## Why does the UniFi installer run?
Ubiquiti have yet to equip the UniFi controller installer with proper silent install support so it is necessary to click through it as normal. 
