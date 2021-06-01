#!/bin/bash
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`

Yahboom="NO"   #YES if you wants to use Yahboom RGB hat bought on Amazon

GPIO_PIN=11    #GPIO Pin number to turn led on and off
INVERT="NO"    #If YES => led ON when okcash crashed, NO => led ON when okcash running

echo -e "\e[93mOkcash Headless Node Led-Status v$Version :\e[0m"
echo -e "wareck@gmail.com"
echo -e ""
echo -e "This script will install led-status addon script and service."
echo -e "Read documentation for installing hardware."
echo -e "\n\e[97mConfiguration\e[0m"
echo -e "-------------"
if [ $Yahboom = "YES" ]
then
echo -e "Yahboom RGB/FAN/OLED Hat : Enabled\n"
else
echo -e "GPIO Pin     : $GPIO_PIN"
echo -e "LED inverted : $INVERT"
fi

if [ -f /boot/dietpi.txt ];then	sudo apt-get install python rpi.gpio -y && DietPi_="YES";else DietPi_="NO";fi
sleep 1
MyUser=$USER

if [ ! -d /home/$USER/scripts ]; then mkdir /home/$USER/scripts ; fi
if [ ! -d /home/$USER/scripts/ledstatus ];then mkdir /home/$USER/scripts/ledstatus ; fi
if [ -f /home/$USER/scripts/ledstatus/ledstatus.sh ]; then rm /home/$USER/scripts/ledstatus/ledstatus.sh; fi
if [ -f /home/$USER/scripts/ledstatus/led_on.py ]; then rm /home/$USER/scripts/ledstatus/led_on.py; fi
if [ -f /home/$USER/scripts/ledstatus/led_off.py ]; then rm /home/$USER/scripts/ledstatus/led_off.py; fi


function common_(){

if [ $INVERT = "NO" ];
then
	XXX="off"
	YYY="on"
else
	XXX="on"
	YYY="off"
fi

echo -e "\n\e[95mBuild ledstatus.sh script :\e[0m"
cat <<'EOF'>> /home/$USER/scripts/ledstatus/ledstatus.sh
#!/bin/bash
## GPIO = PPP
## INVERTED = III : led will be off if okcashd is running , and led on if not .
if  ps -ef | grep -v grep | grep okcashd >/dev/null # check if okcash is running or not
        then
        connexion=$(okcashd getinfo | awk 'NR ==14{print$3}'| sed 's/,//g') #check if it's connected on network and find peers
        reacheable=$(okcashd getnetworkinfo | awk 'NR ==12{print$3}' | sed 's/,//g') # check if it's reachable
        staking=$(okcashd getstakinginfo | awk 'NR ==3{print$3}' | sed 's/,//g') # check if it's Staking
                if [ -z $connexion ];then connexion=0;fi
                if [ -z $reacheable ];then reacheable=0;fi
                if [ -z $staking ];then staking=0;fi
        else
        connexion=0
        reacheable=0
        okcashrun=0
        staking=0
fi


case $connexion in
0)
echo -n -e "Not Connected "
staking="false"
;;
*)
echo -n -e "Connected "
;;
esac

if [ $staking = "true" ]
        then
        echo -n -e "& Staking \n"
        sudo python /home/ZZZ/scripts/ledstatus/led_YYY.py
        else
        echo -n -e "& not Staking \n"
        sudo python /home/ZZZ/scripts/ledstatus/led_XXX.py
fi
EOF
sudo bash -c "sed -i -e 's/ZZZ/$MyUser/g' /home/$USER/scripts/ledstatus/ledstatus.sh"
sudo bash -c "sed -i -e 's/XXX/$XXX/g' /home/$USER/scripts/ledstatus/ledstatus.sh"
sudo bash -c "sed -i -e 's/YYY/$YYY/g' /home/$USER/scripts/ledstatus/ledstatus.sh"
sudo bash -c "sed -i -e 's/PPP/$GPIO_PIN/g' /home/$USER/scripts/ledstatus/ledstatus.sh"
sudo bash -c "sed -i -e 's/III/$INVERT/g' /home/$USER/scripts/ledstatus/ledstatus.sh"
chmod +x /home/$USER/scripts/ledstatus/ledstatus.sh
echo "Done."
}

function hardware_diy(){
echo -e "\n\e[95mBuild led_on.py & led_off.py script :\e[0m"
cat <<EOF>> /home/$USER/scripts/ledstatus/led_on.py
import RPi.GPIO as GPIO
from time import sleep
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup($GPIO_PIN, GPIO.OUT)
GPIO.output($GPIO_PIN,1)
EOF

cat <<EOF>> /home/$USER/scripts/ledstatus/led_off.py
import RPi.GPIO as GPIO
from time import sleep
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup($GPIO_PIN, GPIO.OUT)
GPIO.output($GPIO_PIN,0)
EOF

echo "Done."
}

function yahboom_hat(){
echo -e "\n\e[95mBuild led_on.py & led_off.py script :\e[0m"
if ! [ -x "$(command -v pip)" ];then sudo apt-get install python-pip i2c-tools -y;fi
sudo pip install smbus

cat <<EOF>> /home/$USER/scripts/ledstatus/led_on.py
import smbus
import time
bus = smbus.SMBus(1)

addr = 0x0d
rgb_off_reg = 0x07
Max_LED = 3

def setRGB(num, r, g, b):
    if num >= Max_LED:
        bus.write_byte_data(addr, 0x00, 0xff)
        bus.write_byte_data(addr, 0x01, r&0xff)
        bus.write_byte_data(addr, 0x02, g&0xff)
        bus.write_byte_data(addr, 0x03, b&0xff)
    elif num >= 0:
        bus.write_byte_data(addr, 0x00, num&0xff)
        bus.write_byte_data(addr, 0x01, r&0xff)
        bus.write_byte_data(addr, 0x02, g&0xff)
        bus.write_byte_data(addr, 0x03, b&0xff)

#bus.write_byte_data(addr, rgb_off_reg, 0x00)
time.sleep(1)
setRGB(Max_LED, 0, 0, 255)
EOF
cat <<EOF>> /home/$USER/scripts/ledstatus/led_off.py
import smbus
import time
bus = smbus.SMBus(1)

addr = 0x0d
rgb_off_reg = 0x07
Max_LED = 3

def setRGB(num, r, g, b):
    if num >= Max_LED:
        bus.write_byte_data(addr, 0x00, 0xff)
        bus.write_byte_data(addr, 0x01, r&0xff)
        bus.write_byte_data(addr, 0x02, g&0xff)
        bus.write_byte_data(addr, 0x03, b&0xff)
    elif num >= 0:
        bus.write_byte_data(addr, 0x00, num&0xff)
        bus.write_byte_data(addr, 0x01, r&0xff)
        bus.write_byte_data(addr, 0x02, g&0xff)
        bus.write_byte_data(addr, 0x03, b&0xff)

bus.write_byte_data(addr, rgb_off_reg, 0x00)
time.sleep(1)
setRGB(Max_LED, 0, 0, 0)
EOF
echo -e "Done."
}

common_
if [ $Yahboom = "YES" ]
then
yahboom_hat
else
hardware_diy
fi

echo -e "\n\e[95mAdding Led_status to contab :\e[0m"
if  ! grep "/home/$MyUser/scripts/ledstatus/ledstatus.sh" /etc/crontab >/dev/null
	then
	MyUser=$USER
	echo $MyUser>/tmp/tmp3
	sudo bash -c 'echo "" > /dev/null >>/etc/crontab | sudo -s'
	sudo bash -c 'echo "#Okcash led_status" > /dev/null >>/etc/crontab | sudo -s'
	sudo bash -c 'form=$(cat "/tmp/tmp3") && echo "* * * * * $form /home/$form/scripts/ledstatus/ledstatus.sh" >>/etc/crontab | sudo -s'
fi
echo -e "Done."

echo -e "\n\e[95mStart led_status:\e[0m"
/home/$USER/scripts/ledstatus/ledstatus.sh
echo -e "\nInstall done !"
