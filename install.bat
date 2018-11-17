@ECHO OFF
@TITLE "UniFi As A Service"
setlocal enabledelayedexpansion

::Set the application-specific string vars
SET AppDescription=UniFi
SET IconName=unifi.ico
SET Shortcut_Name=UniFi.url
SET URL_PATH=https://localhost:8443

::Set the common string vars
SET ICONDEST=c:\ProgramData\%AppDescription%
SET LinkPath=%userprofile%\Desktop\%Shortcut_Name%

net session >nul 2>&1
if %errorLevel% NEQ 0 GOTO needadmin


echo #########################################################################
echo #                                                                       #
echo #                  KM                       ,ok0KNWW                    #
echo #                        KM               :NMMMMMMMM                    #
echo #                       KM  ..             WMMMMMMMMM                   #
echo #                   KM      KM             WMMMMMMMMM                   #
echo #                   KM    KM               WMMMMMMMMM                   #
echo #                   KM  KM  ..             WMMMMMMMMM                   #
echo #                   KM  ..  KM             WMMMMMMMMM                   #
echo #                   KM  KM  KM             WMMMMMMMMM                   #
echo #                   KMNXWM  KM             WMMMMMMMMK                   #
echo #                   KMMMMMKONM             WMMMMMMMW                    #
echo #                   KMMMMMMMMM             WMMMMMMM x                   #
echo #                   lMMMMMMMMM             WMMMMMN xK                   #
echo #                    MMMMMMMMMl           ,WMMMP dXM:                   #
echo #                    lMMMMMMMMx .        ,,,aaadXMMd                    #
echo #                     lNMMMMMMW: XOxolcclodOKMMMMWc                     #
echo #                       lXMMMMMNc lMMMMMMMMMMMMNo.                      #
echo #                         llONMMM0c lMMMMMMNOo'                         #
echo #                              'lMN;. lMWl'                             #
echo #                                                                       #
echo #          Unifi controller as a Windows Service Installer              #
echo #########################################################################
echo.
echo.
echo.
:ask
echo This script will install the Unifi Controller Servce
set /P INPUT=Would you like to begin?[Y/N]: %=%
If /I "%INPUT%"=="n" exit
If /I "%INPUT%"=="y" goto yes
echo Please Answer y/n & goto ask

:yes
echo.
echo Punching firewall holes
netsh advfirewall firewall add rule name="8080 for UniFi" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="8443 for UniFi web GUI" dir=in action=allow protocol=TCP localport=8443
netsh advfirewall firewall add rule name="8880 for UniFi" dir=in action=allow protocol=TCP localport=8880
netsh advfirewall firewall add rule name="8843 for UniFi" dir=in action=allow protocol=TCP localport=8843
netsh advfirewall firewall add rule name="10001 for UniFi" dir=in action=allow protocol=UDP localport=10001
netsh advfirewall firewall add rule name="3478 for UniFi" dir=in action=allow protocol=UDP localport=3478
echo.

echo Downloading dependencies
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://esperto.com.au/repo/jre/windows/x64/latest.exe', '%temp%\jre.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://dl.ubnt.com/unifi/5.7.23/UniFi-installer.exe', '%temp%\unifi.exe')"
echo.
echo Killing Unifi if running
taskkill.exe /F /FI "WINDOWTITLE eq Ubiquiti*" >nul 2>&1
echo.
echo Stopping Unifi service if exists
net stop unifi
echo.
echo Installing dependencies
start /w %temp%\jre.exe /s
echo.
echo Installing controller (Click through as normal)
start /w %temp%\unifi.exe /s
echo.
echo Waiting 10 seconds
ping 127.0.0.1 -n 10 > nul
echo.
echo Killing Unifi if running
taskkill.exe /F /FI "WINDOWTITLE eq Ubiquiti*" >nul 2>&1
echo.
echo Purposefully starting Unifi to generate configs
start "" "%userprofile%\Ubiquiti UniFi\lib\ace.jar" "ui"
echo.
echo Waiting 60 seconds for Unifi to come alive
ping 127.0.0.1 -n 60 > nul
echo.
echo Killing Unifi
taskkill.exe /F /FI "WINDOWTITLE eq Ubiquiti*" >nul 2>&1
echo.
echo Installing Unifi as a Service
cd "%userprofile%\Ubiquiti UniFi\"
"C:\ProgramData\Oracle\Java\javapath\java.exe" -jar lib\ace.jar installsvc >nul 2>&1
"C:\ProgramData\Oracle\Java\javapath\java.exe" -jar lib\ace.jar startsvc
echo.
echo Removing default shortcuts
del /F /Q %USERPROFILE%\Desktop\Unifi.lnk"
rmdir /S /Q "%AppData%\Microsoft\Windows\Start Menu\Programs\Ubiquiti UniFi"
echo.
echo Creating desktop icon
IF EXIST "%ICONDEST%" (GOTO _CopyIcon)
mkdir "%ICONDEST%"
:_CopyIcon
copy "%userprofile%\Ubiquiti UniFi\%IconName%" "%ICONDEST%"
echo [InternetShortcut] > "%LinkPath%"
echo URL=%URL_PATH% >> "%LinkPath%"
echo IDList= >> "%LinkPath%"
echo IconFile=%ICONDEST%\%IconName% >> "%LinkPath%"
echo IconIndex=0 >> "%LinkPath%"
echo HotKey=0 >> "%LinkPath%"
echo.
echo.
echo Looks like we are done
echo Press any key to launch the UniFi web GUI and finish
pause > nul
start https://localhost:8443
exit

:needadmin
echo This script needs to be run as Admin
echo.
echo Press any key to exit.
pause > nul
exit
