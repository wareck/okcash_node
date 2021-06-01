#!/bin/bash
I2cAddress="3c"
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`

echo -e "\e[93mOkcash Headless Node Oled-display v$Version :\e[0m"
echo -e "Author:wareck@gmail.com\n"
echo -e "This script will install oled-status add-on script and service."
echo -e "Based on Adafruit ssd1306 script."
echo -e "Read documentation for installing hardware.\n"
if [ -f /boot/dietpi.txt ];then DietPi_="YES";else DietPi_="NO";fi
if [ $DietPi_ = "YES" ]
then
echo -e "\e[38;5;154mDietpi\e[0m image detected:"
echo -e "This script will enable /etc/rc.local for AutoStart (disabled by default on Dietpi).\n"
fi

if ! [ -f /usr/sbin/i2cdetect ];then sudo apt-get install i2c-tools -y ;fi
echo -e "\e[95mHardware check:\e[0m"
Check=$(sudo i2cdetect -y 1 |grep -c $I2cAddress)
if [ $Check = "0" ]
then
echo -e "Oled screen not detected."
echo -e "Standard I2c address is '3c' "
echo -e "\e[91mCheck your hardware installation ! \n\e[0m"
echo -e "\e[91mMaybe you forgot to enable I2c in the raspi-config...\n\e[0m"
sudo i2cdetect -y 1
echo -e "You must see '3c' in this form...\n"
exit
fi
echo -e "Done.\n"

echo -e "\e[95mSoftware check:\e[0m"
if ! [ -x "$(command -v pip3)" ];then sudo apt-get install python3-pip python3-pil -y;fi
sudo apt-get install python3-pil -y
sudo pip3 install adafruit-circuitpython-ssd1306
echo -e "Done.\n"

echo -e "\e[95mScripts build:\e[0m"
if [ -f /home/$USER/scripts/oled.py ] ; then rm /home/$USER/scripts/oled.py ;fi
if [ -f /home/$USER/scripts/oled_ext.sh  ] ; then rm /home/$USER/scripts/oled_ext.sh ;fi
if ! [ -d /home/$USER/scripts ]; then mkdir /home/$USER/scripts;fi

cat <<'EOF'>> /home/$USER/scripts/oled.py
# SPDX-FileCopyrightText: 2017 Tony DiCola for Adafruit Industries
# SPDX-FileCopyrightText: 2017 James DeVito for Adafruit Industries
# SPDX-License-Identifier: MIT

# This example is for use on (Linux) computers that are using CPython with
# Adafruit Blinka to support CircuitPython libraries. CircuitPython does
# not support PIL/pillow (python imaging library)!

import time
import subprocess
import sys

from board import SCL, SDA
import busio
from PIL import Image, ImageDraw, ImageFont
import adafruit_ssd1306


# Create the I2C interface.
i2c = busio.I2C(SCL, SDA)

# Create the SSD1306 OLED class.
# The first two parameters are the pixel width and pixel height.  Change these
# to the right size for your display!
disp = adafruit_ssd1306.SSD1306_I2C(128, 32, i2c)

# Clear display.
disp.fill(0)
disp.show()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new("1", (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0, 0, width, height), outline=0, fill=0)

# Draw some shapes.
# First define some constants to allow easy resizing of shapes.
padding = -2
top = padding
bottom = height - padding
# Move left to right keeping track of the current x position for drawing shapes.
x = 0


# Load default font.
font = ImageFont.load_default()

# Alternatively load a TTF font.  Make sure the .ttf font file is in the
# same directory as the python script!
# Some other nice fonts to try: http://www.dafont.com/bitmap.php
# font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 9)


# Draw a black filled box to clear the image.
draw.rectangle((0, 0, width, height), outline=0, fill=0)

# Shell scripts for system monitoring from here:
# https://unix.stackexchange.com/questions/119126/command-to-display-memory-usage-disk-usage-and-cpu-load
cmd = "hostname -I | awk '{print$1}'"
IP = subprocess.check_output(cmd, shell=True).decode("utf-8")
cmd = 'cat /tmp/oled.tmp | head -1'
Conn = subprocess.check_output(cmd, shell=True).decode("utf-8")
cmd = 'cat /tmp/oled.tmp | sed -n 2p'
Stake = subprocess.check_output(cmd, shell=True).decode("utf-8")
cmd = 'cat /tmp/oled.tmp | sed -n 3p'
Wall = subprocess.check_output(cmd, shell=True).decode("utf-8")

# Write four lines of text.

draw.text((x, top + 0), "IP:" + IP, font=font, fill=255)
draw.text((x, top + 8), "Connections:" + Conn, font=font, fill=255)
draw.text((x, top + 16), "Wallet:" + Wall, font=font, fill=255)
draw.text((x, top + 25), "Stake:" + Stake, font=font, fill=255)

# Display image.
disp.image(image)
disp.show()
time.sleep(0.1)
EOF

cat <<'EOF'>> /home/$USER/scripts/oled_ext.sh
#!/bin/bash
if ! [ -f /tmp/oled.tmp ]
then
echo "0" >/tmp/oled.tmp
echo "starting" >>/tmp/oled.tmp
echo "starting" >>/tmp/oled.tmp
else
if [ -f /tmp/oled.tmp ];then rm /tmp/oled.tmp;fi
okcashd getinfo | grep "connections" |awk '{print$3}'| sed 's/,//g' >/tmp/oled.tmp
okcashd getstakinginfo |grep "staking" | awk '{print$3}' |sed 's/,//g' >>/tmp/oled.tmp
printf "%.0f" $(okcashd getwalletinfo | grep "balance" |awk '{print$3}'| sed 's/,//g') >>/tmp/oled.tmp
sudo python3 /home/XXXX/scripts/oled.py
fi
EOF
bash -c "sed -i -e 's/XXXX/$USER/g' /home/$USER/scripts/oled_ext.sh"
chmod +x /home/$USER/scripts/oled_ext.sh
echo -e "Done."

echo -e "\n\e[95mAdding Oled-status to startup:\e[0m"
if [ $DietPi_ = "NO" ]
then
if ! grep "#Oled_status init" /etc/rc.local >/dev/null 2>&1
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo "#Oled_status init" >>/etc/rc.local'
sudo bash -c 'echo "su - pi -c '\''/home/pi/scripts/oled_ext.sh'\''" >>/etc/rc.local'
sudo bash -c 'echo "python3 /home/pi/scripts/oled.py &" >>/etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
fi
echo -e "Done."
else #Dietpi
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
if ! [ -f /lib/systemd/system/rc-local.service ]
then
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
fi

if ! grep "#Oled_status init" /etc/rc.local >/dev/null 2>&1
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo "#Oled_status init" >>/etc/rc.local'
sudo bash -c 'echo "su - dietpi -c '\''/home/dietpi/scripts/oled_ext.sh'\''" >>/etc/rc.local'
sudo bash -c 'echo "sudo python3 /home/dietpi/scripts/oled.py &" >>/etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
sudo chmod +x /etc/rc.local
fi
echo -e "Done."
fi

echo -e "\n\e[95mAdding Oled_status to contab :\e[0m"
if  ! grep "oled_ext.sh" /etc/crontab >/dev/null
        then
        MyUser=$USER
        echo $MyUser>/tmp/tmp3
        sudo bash -c 'echo "" > /dev/null >>/etc/crontab | sudo -s'
        sudo bash -c 'echo "#Okcash oled_status" > /dev/null >>/etc/crontab | sudo -s'
        sudo bash -c 'form=$(cat "/tmp/tmp3") && echo "* * * * * $form /home/$form/scripts/oled_ext.sh" >>/etc/crontab | sudo -s'
fi
echo -e "Done. \n"
