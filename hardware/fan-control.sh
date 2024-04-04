#!/bin/bash
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`

################
#Configuration :
###############
Hardware="Noctua"
#DIY for your own FAN build
#Noctua for 5v 40x40 Noctua fan
#Yahboom for fan hat Yahboom bought on Amazon

GPIO_PIN=18    #physical GPIO Pin number to turn fan on and off
Start_TEMP=53 #Start temperature in Celsius
Gap_TEMP=5    #Wait until the temperature is X degrees under the Max before shutting off
PWM=0

echo -e "\n\e[93mOkcash headless Node auto-fan v$Version:\e[0m"
echo -e "wareck@free.fr"
echo -e ""
echo -e "This script will install auto-fan control script and service."
echo -e "Read documentation for installing hardware."
echo -e "\n\e[97mConfiguration\e[0m"
echo -e "-------------"

Hardware=${Hardware^^}


if [ $Hardware = "YAHBOOM" ]
then
echo -e "Yahboom RGB/FAN/oled Hat : Enabled\n"
echo -e "GPIO Pin    : $GPIO_PIN"
echo -e "Start Temp  : $Start_TEMP°C"
echo -e "Gap Temp    : $Gap_TEMP°C"
if [ $PWM = 1 ]
then
echo -e "PWM mode    : \e[93mEnabled\e[0m"
else
echo -e "PWM mode    : Disabled"
fi
sleep 2
fi

if [ $Hardware = "NOCTUA" ]
then
GPIO_PIN=18
echo -e "Noctua 5v 40x40 FAN"
echo -e "GPIO Pin    : $GPIO_PIN"
echo -e "Start Temp  : $Start_TEMP°C"
echo -e "Gap Temp    : $Gap_TEMP°C"
fi



if ! [ -x /opt/vc/bin/vcgencmd ]
then
echo -e "\n\e[95mBuild Userland Pack :\e[0m"
#build from source:
#sudo apt-get install cmake git -y
#echo -e ""
#git clone https://github.com/raspberrypi/userland
#echo -e ""
#cd userland
#./buildme
#cd ..
#rm -r -f userland
sudo dpkg -i ../files/userland_1.51-1_armhf.deb
rm -r -f userland
sudo rm /opt/vc/bin/vcgencmd
sudo cp /usr/bin/vcgencmd /opt/vc/bin/vcgencmd
fi

function Noctua_fan (){
echo -e "\n\e[95mBuild run-fan.py script :\e[0m"
MyUser=$USER
if [ -f /boot/dietpi.txt ];then sudo apt-get install python rpi.gpio -y && DietPi_="YES";else DietPi_="NO";fi
if [ ! -d /home/$USER/scripts ];then mkdir /home/$USER/scripts ; fi
if [ -f /home/$USER/scripts/run-fan.py ];then rm /home/$USER/scripts/run-fan.py ; fi
cat <<'EOF'>> /home/$USER/scripts/run-fan.py
#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time
import signal
import sys
import os

# Configuration
GPIO_PIN = XXXXX        # BCM pin used to drive PWM fan
WAIT_TIME = 1           # [s] Time to wait between each refresh
PWM_FREQ = 25           # [kHz] 25kHz for Noctua PWM control

# Configurable temperature and fan speed
MIN_TEMP = YYYYY
MAX_TEMP = 70
FAN_LOW = 40
FAN_HIGH = 100
FAN_OFF = 0
FAN_MAX = 100

# Get CPU's temperature
def getCpuTemperature():
    res = os.popen('vcgencmd measure_temp').readline()
    temp =(res.replace("temp=","").replace("'C\n",""))
    #print("temp is {0}".format(temp)) # Uncomment for testing
    return temp

# Set fan speed
def setFanSpeed(speed):
    fan.start(speed)
    return()

# Handle fan speed
def handleFanSpeed():
    temp = float(getCpuTemperature())
    # Turn off the fan if temperature is below MIN_TEMP
    if temp < MIN_TEMP:
        setFanSpeed(FAN_OFF)
        #print("Fan OFF") # Uncomment for testing
    # Set fan speed to MAXIMUM if the temperature is above MAX_TEMP
    elif temp > MAX_TEMP:
        setFanSpeed(FAN_MAX)
        #print("Fan MAX") # Uncomment for testing
    # Caculate dynamic fan speed
    else:
        step = (FAN_HIGH - FAN_LOW)/(MAX_TEMP - MIN_TEMP)
        temp -= MIN_TEMP
        setFanSpeed(FAN_LOW + ( round(temp) * step ))
        #print(FAN_LOW + ( round(temp) * step )) # Uncomment for testing
    return ()

try:
    # Setup GPIO pin
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(GPIO_PIN, GPIO.OUT, initial=GPIO.LOW)
    fan = GPIO.PWM(GPIO_PIN,PWM_FREQ)
    setFanSpeed(FAN_OFF)
    # Handle fan speed every WAIT_TIME sec
    while True:
        handleFanSpeed()
        time.sleep(WAIT_TIME)

except KeyboardInterrupt: # trap a CTRL+C keyboard interrupt
    setFanSpeed(FAN_HIGH)
    #GPIO.cleanup() # resets all GPIO ports used by this function
EOF

echo -e "\n\e[95mApply Configuration :\e[0m"
sed -i -e "s/XXXXX/$GPIO_PIN/g" /home/$USER/scripts/run-fan.py
sed -i -e "s/YYYYY/$Start_TEMP/g" /home/$USER/scripts/run-fan.py
echo -e "Done."

echo -e "\n\e[95mBuild run-fan.service script :\e[0m"
if [ -f /tmp/run-fan.service ]; then rm /tmp/run-fan.service;fi
sudo cat <<'EOF'>> /tmp/run-fan.service
[Unit]
Description=autofan control
After=meadiacenter.service
[Service]
   User=root
   Group=root
   Type=simple
   ExecStart=/usr/bin/python /home/XXX/scripts/run-fan.py
   Restart=always

  [Install]
   WantedBy=multi-user.target
EOF
sed -i -e "s/XXX/$MyUser/g" /tmp/run-fan.service
if [ $DietPi_ = "NO" ]
then
OSV=$(sed 's/\..*//' /etc/debian_version)
if [ $OSV = 11 ]
then sed -i -e "s/python/python3/g" /tmp/run-fan.service
fi
fi
sudo bash -c 'cp /tmp/run-fan.service /lib/systemd/system/ | sudo -s'
echo -e "Done"
sleep 1

sudo systemctl daemon-reload
sudo systemctl enable run-fan.service
}

function hardware_diy(){
echo -e "\n\e[95mBuild run-fan.py script :\e[0m"
MyUser=$USER
if [ -f /boot/dietpi.txt ];then sudo apt-get install python rpi.gpio -y && DietPi_="YES";else DietPi_="NO";fi
if [ ! -d /home/$USER/scripts ];then mkdir /home/$USER/scripts ; fi
if [ -f /home/$USER/scripts/run-fan.py ];then rm /home/$USER/scripts/run-fan.py ; fi

if [ $PWM = 0 ]
then
cat <<'EOF'>> /home/$USER/scripts/run-fan.py
#!/usr/bin/env python3
import subprocess
import time

from gpiozero import OutputDevice


ON_THRESHOLD = YYYYY  # (degrees Celsius) Fan kicks on at this temperature.
OFF_THRESHOLD = ZZZZZ # (degress Celsius) Fan shuts off at this temperature.
SLEEP_INTERVAL = 5  # (seconds) How often we check the core temperature.
GPIO_PIN = XXXXX  # Which GPIO pin you're using to control the fan.


def get_temp():
    """Get the core temperature.
    Run a shell script to get the core temp and parse the output.
    Raises:
        RuntimeError: if response cannot be parsed.
    Returns:
        float: The core temperature in degrees Celsius.
    """
    output = subprocess.run(['vcgencmd', 'measure_temp'], capture_output=True)
    temp_str = output.stdout.decode()
    try:
        return float(temp_str.split('=')[1].split('\'')[0])
    except (IndexError, ValueError):
        raise RuntimeError('Could not parse temperature output.')


if __name__ == '__main__':
    # Validate the on and off thresholds
    if OFF_THRESHOLD >= ON_THRESHOLD:
        raise RuntimeError('OFF_THRESHOLD must be less than ON_THRESHOLD')

    fan = OutputDevice(GPIO_PIN)

    while True:
        temp = get_temp()

        # Start the fan if the temperature has reached the limit and the fan
        # isn't already running.
        # NOTE: `fan.value` returns 1 for "on" and 0 for "off"
        if temp > ON_THRESHOLD and not fan.value:
            fan.on()

        # Stop the fan if the fan is running and the temperature has dropped
        # to 10 degrees below the limit.
        elif fan.value and temp < OFF_THRESHOLD:
            fan.off()

        time.sleep(SLEEP_INTERVAL)
EOF
fi

if [ $PWM = 1 ]
then
cat <<'EOF'>> /home/$USER/scripts/run-fan.py
#!/usr/bin/env python3
# Author: Andreas Spiess
import os
import time
from time import sleep
import signal
import sys
import RPi.GPIO as GPIO

fanPin = XXXXX # The pin ID, edit here to change it

desiredTemp = YYYYY # The maximum temperature in Celsius after which we trigger the fan

fanSpeed=100
sum=0
pTemp=15
iTemp=0.4

def getCPUtemperature():
    res = os.popen('vcgencmd measure_temp').readline()
    temp =(res.replace("temp=","").replace("'C\n",""))
    #print("temp is {0}".format(temp)) #Uncomment here for testing
    return temp
def fanOFF():
    myPWM.ChangeDutyCycle(0)   # switch fan off
    return()
def handleFan():
    global fanSpeed,sum
    actualTemp = float(getCPUtemperature())
    diff=actualTemp-desiredTemp
    sum=sum+diff
    pDiff=diff*pTemp
    iDiff=sum*iTemp
    fanSpeed=pDiff +iDiff
    if fanSpeed>100:
        fanSpeed=100
    if fanSpeed<15:
        fanSpeed=0
    if sum>100:
        sum=100
    if sum<-100:
        sum=-100
    #print("actualTemp %4.2f TempDiff %4.2f pDiff %4.2f iDiff %4.2f fanSpeed %5d" % (actualTemp,diff,pDiff,iDiff,fanSpeed))
    myPWM.ChangeDutyCycle(fanSpeed)
    return()
def setPin(mode): # A little redundant function but useful if you want to add logging
    GPIO.output(fanPin, mode)
    return()
try:
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(fanPin, GPIO.OUT)
    myPWM=GPIO.PWM(fanPin,50)
    myPWM.start(50)
    GPIO.setwarnings(False)
    fanOFF()
    while True:
        handleFan()
        sleep(1) # Read the temperature every 5 sec, increase or decrease this limit if you want
except KeyboardInterrupt: # trap a CTRL+C keyboard interrupt
    fanOFF()
    GPIO.cleanup() # resets all GPIO ports used by this program
EOF
fi

chmod +x /home/$USER/scripts/run-fan.py
echo -e "Done."

if [ $PWM = 0 ]
then
echo -e "\n\e[95mApply Configuration :\e[0m"
sed -i -e "s/XXXXX/$GPIO_PIN/g" /home/$USER/scripts/run-fan.py
sed -i -e "s/YYYYY/$Start_TEMP/g" /home/$USER/scripts/run-fan.py
Threshold=$(expr $Start_TEMP - $Gap_TEMP)
sed -i -e "s/ZZZZZ/$Threshold/g" /home/$USER/scripts/run-fan.py
echo -e "Done."
fi

if [ $PWM = 1 ]
then
echo -e "\n\e[95mApply Configuration :\e[0m"
sed -i -e "s/XXXXX/$GPIO_PIN/g" /home/$USER/scripts/run-fan.py
sed -i -e "s/YYYYY/$Start_TEMP/g" /home/$USER/scripts/run-fan.py
echo -e "Done."
fi

echo -e "\n\e[95mBuild run-fan.service script :\e[0m"
if [ -f /tmp/run-fan.service ]; then rm /tmp/run-fan.service;fi
sudo cat <<'EOF'>> /tmp/run-fan.service
[Unit]
Description=autofan control
After=meadiacenter.service
[Service]
   User=root
   Group=root
   Type=simple
   ExecStart=/usr/bin/python /home/XXX/scripts/run-fan.py
   Restart=always

  [Install]
   WantedBy=multi-user.target
EOF
sed -i -e "s/XXX/$MyUser/g" /tmp/run-fan.service
if [ $DietPi_ = "NO" ]
then
OSV=$(sed 's/\..*//' /etc/debian_version)
if [ $OSV = 11 ]
then sed -i -e "s/python/python3/g" /tmp/run-fan.service
fi
fi
sudo bash -c 'cp /tmp/run-fan.service /lib/systemd/system/ | sudo -s'
echo -e "Done"
sleep 1

sudo systemctl daemon-reload
sudo systemctl enable run-fan.service
sleep 5
}

function Yahboom_hat(){
echo -e "This script will build service for autofan linked to cpu temp."
echo -e "Works with Yahboom! RGB/FAN/OLED hat bought on Amazon."
echo -e ""
sleep 2
echo -e "\n\e[95mBuild run-fan.py script :\e[0m"
if [ -f /boot/dietpi.txt ]
then
sudo apt-get install python rpi.gpio -y
fi
MyUser=$USER
if ! [ -x "$(command -v pip3)" ];then sudo apt-get install python3-pip i2c-tools -y;fi
sudo pip3 install smbus
sudo pip3 install --upgrade RPi.GPIO
if [ ! -d /home/$USER/scripts ];then mkdir /home/$USER/scripts ; fi
if [ -f /home/$USER/scripts/run-fan.py ];then rm /home/$USER/scripts/run-fan.py ; fi
cat <<'EOF'>> /home/$USER/scripts/run-fan.py
import smbus
import time
import os
bus = smbus.SMBus(1)

addr = 0x0d
fan_reg = 0x08
state = 0
temp = 0
level_temp = 0

while True:
    cmd = os.popen('vcgencmd measure_temp').readline()
    CPU_TEMP = cmd.replace("temp=","").replace("'C\n","")
    # print(CPU_TEMP)
    temp = float(CPU_TEMP)

    if abs(temp - level_temp) >= 1:
        if temp <= 45:
            level_temp = 45
            bus.write_byte_data(addr, fan_reg, 0x00)
        elif temp <= 47:
            level_temp = 47
            bus.write_byte_data(addr, fan_reg, 0x04)
        elif temp <= 49:
            level_temp = 49
            bus.write_byte_data(addr, fan_reg, 0x06)
        elif temp <= 51:
            level_temp = 51
            bus.write_byte_data(addr, fan_reg, 0x08)
        elif temp <= 53:
            level_temp = 53
            bus.write_byte_data(addr, fan_reg, 0x09)
        else:
            level_temp = 55
            bus.write_byte_data(addr, fan_reg, 0x01)

    time.sleep(1)
EOF
echo -e "Done."
echo -e "\n\e[95mBuild run-fan.service script :\e[0m"
if [ -f /tmp/run-fan.service ]; then rm /tmp/run-fan.service;fi
sudo cat <<'EOF'>> /tmp/run-fan.service
[Unit]
Description=autofan control
After=meadiacenter.service
[Service]
   User=root
   Group=root
   Type=simple
   ExecStart=/usr/bin/python3 /home/XXX/scripts/run-fan.py
   Restart=always

  [Install]
   WantedBy=multi-user.target
EOF
sed -i -e "s/XXX/$MyUser/g" /tmp/run-fan.service
sudo bash -c 'cp /tmp/run-fan.service /lib/systemd/system/ | sudo -s'
sleep 1
sudo systemctl daemon-reload
sudo systemctl enable run-fan.service
sleep 1
echo -e "Done"
}

case $Hardware in
YAHBOOM)
	Yahboom_hat
	;;
NOCTUA)
	Noctua_fan
	;;
DIY)
	hardware_diy
	;;
*)
	echo "config error"
	exit
	;;
esac
echo -e "\n\e[97mInstall is finished !!!\e[0m"
echo ""
