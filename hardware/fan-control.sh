#!/bin/bash
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`

################
#Configuration :
###############
Yahboom="NO"  #YES if you use Yahboom RGB/OLED/FAN Hat bought on Amazon

GPIO_PIN=4    #GPIO Pin number to turn fan on and off
Start_TEMP=50 #Start temperature in Celsius
Gap_TEMP=3.0  #Wait until the temperature is X degrees under the Max before shutting off
PWM=0

echo -e "\n\e[93mOkcash headless Node auto-fan v$Version:\e[0m"
echo -e "wareck@gmail.com"
echo -e ""
echo -e "This script will install auto-fan control script and service."
echo -e "Read documentation for installing hardware."
echo -e "\n\e[97mConfiguration\e[0m"
echo -e "-------------"
if [ $Yahboom = "YES" ]
then
echo -e "Yahboom RGB/FAN/oled Hat : Enabled\n"
else
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

function hardware_diy(){
echo -e "\n\e[95mBuild run-fan.py script :\e[0m"
MyUser=$USER
if [ -f /boot/dietpi.txt ];then sudo apt-get install python rpi.gpio -y && DietPi_="YES";else DietPi_="NO";fi
if [ ! -d /home/$USER/scripts ];then mkdir /home/$USER/scripts ; fi
if [ -f /home/$USER/scripts/run-fan.py ];then rm /home/$USER/scripts/run-fan.py ; fi

if [ $PWM = 0 ]
then
cat <<'EOF'>> /home/$USER/scripts/run-fan.py
#!/usr/bin/env python

#########################
#
# The original script is from:
#    Author: Edoardo Paolo Scalafiotti <edoardo849@gmail.com>
#    Source: https://hackernoon.com/how-to-control-a-fan-to-cool-the-cpu-of-your-raspberrypi-3313b6e7f92c
#
#########################

#########################
import os
import time
import signal
import sys
import RPi.GPIO as GPIO
import datetime

#########################
sleepTime = 30	# Time to sleep between checking the temperature
                # want to write unbuffered to file
fileLog = open('/tmp/run-fan.log', 'w+', 0)

#########################
# Log messages should be time stamped
def timeStamp():
    t = time.time()
    s = datetime.datetime.fromtimestamp(t).strftime('%Y/%m/%d %H:%M:%S - ')
    return s

# Write messages in a standard format
def printMsg(s):
    fileLog.write(timeStamp() + s + "\n")

#########################
class Pin(object):
    pin = XXXXX     # GPIO or BCM pin number to turn fan on and off

    def __init__(self):
        try:
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(self.pin, GPIO.OUT)
            GPIO.setwarnings(False)
            printMsg("Initialized: run-fan using GPIO pin: " + str(self.pin))
        except:
            printMsg("If method setup doesn't work, need to run script as sudo")
            exit

    # resets all GPIO ports used by this program
    def exitPin(self):
        GPIO.cleanup()

    def set(self, state):
        GPIO.output(self.pin, state)

# Fan class
class Fan(object):
    fanOff = True

    def __init__(self):
        self.fanOff = True

    # Turn the fan on or off
    def setFan(self, temp, on, myPin):
        if on:
            printMsg("Turning fan on " + str(temp))
        else:
            printMsg("Turning fan off " + str(temp))
        myPin.set(on)
        self.fanOff = not on

# Temperature class
class Temperature(object):
    cpuTemperature = 0.0
    startTemperature = 0.0
    stopTemperature = 0.0

    def __init__(self):
        # Start temperature in Celsius
        #   Maximum operating temperature of Raspberry Pi 3 is 85C
        #   CPU performance is throttled at 82C
        #   running a CPU at lower temperatures will prolong its life
        self.startTemperature = YYYYY

        # Wait until the temperature is M degrees under the Max before shutting off
        self.stopTemperature = self.startTemperature - ZZZZZ

        printMsg("Start fan at: " + str(self.startTemperature))
        printMsg("Stop fan at: " + str(self.stopTemperature))

    def getTemperature(self):
        # need to specify path for vcgencmd
        res = os.popen('/opt/vc/bin/vcgencmd measure_temp').readline()
        self.cpuTemperature = float((res.replace("temp=","").replace("'C\n","")))

    # Using the CPU's temperature, turn the fan on or off
    def checkTemperature(self, myFan, myPin):
        self.getTemperature()
        if self.cpuTemperature > self.startTemperature:
            # need to turn fan on, but only if the fan is off
            if myFan.fanOff:
                myFan.setFan(self.cpuTemperature, True, myPin)
        else:
            # need to turn fan off, but only if the fan is on
            if not myFan.fanOff:
                myFan.setFan(self.cpuTemperature, False, myPin)

#########################
printMsg("Starting: run-fan")
try:
    myPin = Pin()
    myFan = Fan()
    myTemp = Temperature()
    while True:
        myTemp.checkTemperature(myFan, myPin)

        # Read the temperature every N sec (sleepTime)
        # Turning a device on & off can wear it out
        time.sleep(sleepTime)

except KeyboardInterrupt: # trap a CTRL+C keyboard interrupt
    printMsg("keyboard exception occurred")
    myPin.exitPin()
    fileLog.close()

except:
    printMsg("ERROR: an unhandled exception occurred")
    myPin.exitPin()
    fileLog.close()
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
sed -i -e "s/ZZZZZ/$Gap_TEMP/g" /home/$USER/scripts/run-fan.py
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
#if [ $DietPi_ = "YES" ]
#then sed -i -e "s/python3/python/g" /tmp/run-fan.service
#fi
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

if [ $Yahboom = "YES" ]
then
Yahboom_hat
else
hardware_diy
fi

echo -e "\n\e[97mInstall is finished !!!\e[0m"
echo ""
