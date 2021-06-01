## DietPi OKcash Node: 
Step 1: ***Burn sdcard***
Download last DietPi image :  https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z

Decompress it (use 7zip)

Download Balena-etcher : https://www.balena.io/etcher/

Use Balenaetcher to burn image on you sdcard:

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_1.png)

Step 2: ***Edit Dietpi.txt***
open the sdcard  (called "boot")

***open file "dietpi.txt"***

adjust values for your setup (here is my setup):

AUTO_SETUP_TIMEZONE=Europe/Paris 

AUTO_SETUP_NET_ETHERNET_ENABLED=1

AUTO_SETUP_NET_WIFI_ENABLED=1 

AUTO_SETUP_NET_WIFI_COUNTRY_CODE=FR

AUTO_SETUP_NET_HOSTNAME=Node AUTO_SETUP_HEADLESS=1

Save file...



***Open file "dietpi-wifi.txt" for wifi setup***

adjust values for your wifi setup (optional if you use ethernet)

Save file.

Now you can install sdcard in the Raspberry and start it.
Wait 2 minutes for start.

Then login to dietpi:
you can use Putty : https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

For finding raspberry on your network : https://github.com/adafruit/Adafruit-Pi-Finder/releases/latest 

Connect to Raspberry : 

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_2.png)

    Initial user is root
    initial password is dietpi

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_3.png)

Accept conditions:

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_4.png)

Change passwords (for root user and dietpi user)

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_5.png)

Now you will have this menu :

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_7.png)

Adjust setup with "dietpi-config" like for me :

 - enabled i2c for my RTC hardware
 - change the display option => GPU/RAM split to 16 (I will not use screen on my node)
 - Regional locale
 
 **Mandatory for OKcash :** 
 
 - You need to enable "OpenSSH server"
 - Autostart options : Custom

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_8.png)

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_9.png)

Now validate changes :

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_10.png)

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_11.png)

wait install is finished

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/dietpi/dietpi_12.png)

then reboot raspberry:

    sudo reboot

Wait 3 minutes raspberry boot...

Login with putty

    user is => dietpi
    password is your password...

Now make a folder for user :

    sudo mkdir /home/dietpi
    sudo chown -R dietpi /home/dietpi
    cd ~

Your raspberry is ready to start install node !

check [install-node.md](https://github.com/wareck/okcash_node/blob/master/docs/install-node.md) doc for the next steps and finalize installation....
