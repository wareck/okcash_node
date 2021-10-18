#!/bin/bash
set -e
Version=1.1

echo -e "\e[93mRTC hardware addon v$Version :\e[0m"
echo -e "wareck@gmail.com"
echo -e ""

if [ -f /boot/dietpi.txt ];then DietPi_="YES";else DietPi_="NO";fi

if ! [ -f .rtc ]
then
echo -e "This script will install RTC addon."
echo -e "This will be done in three steps:"
echo -e "1: Enable and install i2c prototcol to dialog with RTC board."
echo -e "2: Reboot."
echo -e "3: Install software , init RTC clock and synchronise clock."
echo -e ""
echo -e "After reboot, start this script again to do the second step."
echo -e
if [ $DietPi_ = "YES" ]
then
echo -e "\e[38;5;154mDietpi\e[0m image detected:"
echo -e "This script will enable /etc/rc.local for AutoStart"
echo -e "(disabled by default on Dietpi).\n"
fi
read -n 1 -r -s -p "Press any key to continue..."

echo -e "\n\n\e[95mRaspberry update :\e[0m"
sudo apt-get update
echo -e "\n\e[95mInstalling libraries :\e[0m"
sudo apt install python-smbus python3-smbus python-dev python3-dev i2c-tools rpi.gpio -y
if ! grep "dtparam=i2c1=on" /boot/config.txt
then
sudo bash -c 'echo "" >>/boot/config.txt'
sudo bash -c 'echo "# Enable i2c for RTC" >>/boot/config.txt'
sudo bash -c 'echo "dtparam=i2c1=on" >>/boot/config.txt'
fi
if ! grep "i2c-dev" /etc/modules ; then sudo bash -c 'echo "i2c-dev" >>/etc/modules';fi
if ! grep "i2c-bcm2708" /etc/modules ; then sudo bash -c 'echo "i2c-bcm2708" >>/etc/modules';fi
if ! grep "rtc-ds1307" /etc/modules ; then sudo bash -c 'echo "rtc-ds1307" >>/etc/modules';fi
if ! grep "rtc-pcf8563"  /etc/modules ; then sudo bash -c 'echo "rtc-pcf8563" >>/etc/modules';fi
if ! grep "dtoverlay=i2c-rtc,ds1307" /boot/config.txt >/dev/null
then
sudo bash -c 'echo "" >>/boot/config.txt'
sudo bash -c 'echo "# RTC clock ds1307 based" >>/boot/config.txt'
sudo bash -c 'echo "dtoverlay=i2c-rtc,ds1307" >>/boot/config.txt'
fi
echo -e "\n\e[31mFirst step of RTC install was done.\e[0m"
echo -e "\e[31mYou need to reboot and start rtc.sh again!\n\e[0m"
touch .rtc && exit 0
fi

function Startup_ {
echo -e "\n\e[95mAdding RTC to RPI startup:\e[0m"
if [ $DietPi_ = "YES" ];then Dietpi_startup_;fi
if ! grep "echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device || true" /etc/rc.local >/dev/null 2>&1
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo "#RTC module init" >>/etc/rc.local'
sudo bash -c 'echo "echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device || true" >> /etc/rc.local'
sudo bash -c 'echo "sudo hwclock -s" >>/etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
fi
echo -e "Done."

echo -e "\n\e[95mDisable fake RTC service:\e[0m"
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable fake-hwclock || true
sudo systemctl disable fake-hwclock.service || true
echo -e "Done."
echo -e "\n\e[95mRTC Checks:\e[0m"
echo -e -n "Internal   time: "
date
echo -e -n "RTC module time: "
sudo bash -c 'hwclock -r'
echo -e ""
echo -e "\e[97mRTC Installation was finish !\e[0m\n"
}

function install_step2 {
sudo modprobe i2c-dev
echo -e "\n\e[95mCreate device:\e[0m"
sudo bash -c 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device > /dev/null 2>&1' || true
echo "Done."
echo -e "\n\e[95mRTC clock reset:\e[0m"
sudo bash -c 'hwclock -r'
echo -e "\n\e[95mRTC clock setup :\e[0m"
sudo bash -c 'hwclock -w'
echo "Done."
Startup_
}


function Dietpi_startup_ {
if ! [ -f /etc/rc.local ]
then
cat <<'EOF'>>/tmp/rc.local
#!/bin/bash
exit 0
EOF
sudo cp /tmp/rc.local /etc/
sudo chmod +x /etc/rc.local
fi

sudo systemctl disable rc-local
sudo systemctl disable rc.local

cat <<'EOF'>> /tmp/rc-local.service
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

# This unit gets pulled automatically into multi-user.target by
# systemd-rc-local-generator if /etc/rc.local is executable.
[Unit]
Description=/etc/rc.local Compatibility
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
EOF

sudo cp /tmp/rc-local.service /lib/systemd/system/rc-local.service
sudo systemctl daemon-reload
}

function rtc_check {
echo -e "\e[95m...Install step 2...\e[0m\n"
echo -e "\e[95mRTC check :\e[0m"
sudo su -c 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device' > /dev/null 2>&1 | true
sudo i2cdetect -y 1
echo -e "\e[31mDS1307 RTC module:  You must see \"UU\" on address 68.\e[0m"
echo -e "\e[31mPCf8563 RTC module: You must see \"UU\" on address 51.\e[0m"
echo -e "\e[31mIf not, double check your wiring and try again.\e[0m"
echo -e "\e[31mIf still not, choose \"Quit\" and follow instructions.\e[0m\n"

PS3='
Please enter your choice: '
options=("Check again" "Continue" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Check again")
	    rtc_check
	    break
            ;;
        "Continue")
            break
	    ;;
        "Quit")
            echo -e "\n\e[93mIf you don't have \"UU\" on address 68\e[0m:"
	    echo -e "\n\e[93mFirst double check your wiring.\e[0m\n"
	    echo -e "\e[93mthen type :\e[0m"
            echo -e "\e[93msudo su\e[0m"
	    echo -e "\e[93mecho ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device\e[0m"
	    echo -e "\e[93mexit\e[0m"
	    echo -e ""
	    echo -e "\e[93mthen \e[0m"
	    echo -e "\e[93m./rtc.sh\n\e[0m"
	    exit 0 && break
            ;;
        *) echo invalid option;;
    esac
done
}

if [ -f .rtc ]
then
rtc_check
install_step2
fi
