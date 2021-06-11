![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/logo.png)

----------
# Okcash full autonomous node running on Raspberry Pi ##


This script build "Okcash headless daemon node" (okcashd command line only, for best efficiency) .
It will make okcashd with static libraries for a better compatibility/efficiency.
This script will download/compile/configure and build all files autonomously . (it take between 2 and 3 hours)
I suggest to use Pi3 or Pi4 otherwise, it will take to much time to synchronise and never staking ...
You can use Raspbian buster (lite or full, better is to use lite version for efficiency/speed) or DietPi (smaller image, optimized packets)


**Note:**

***Due to the recent database increase, okcash need more power and more memory to works. At the first start, to stakes coin, okcash need enough memory to open database, check blockchain and works on files. Thats why, since april 2020, this node do not work anymore on old Raspberry Pi. I suggest to use a Raspberry Pi3 or higher with a fast sdcard, a SSD drive or a fast USB key. Actually, this software work at home on a raspberry pi4 and a kingston high speed usb key with a 8gb sdcard.***

----------
This script has been extensively tested and still works on my personal node.

Works on Raspberry OS and Dietpi (32bit)

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/software.png)


----------

**Note:**

Actual setup is:
Okcash : v6.9.0.5 (Github last official release)
OpenSSL :v1.0.2r
LibBoost :v1.67.0
libDB : v4.8.30.NC
Miniupnpc : v2.2.2 


**Software installation:**

Quick start :

    git clone https://github.com/wareck/okcash_node_raspberry.git
    cd okcash_node
    ./build.sh
    

**Extended documentations links:**

 - [lnstall-node](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/install-node.md)
 - [DietPi-build](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/dietpi.md)
 - [Fan-control](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/fan_control.md)
 - [Led-status](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/led-status.md)
 - [Usb](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/usb.md)
 - [Oled LCD](https://github.com/wareck/okcash_node_raspberry/blob/master/docs/oled.md)

**Donate:**
 - Bitcoin: 1Pu12Wimuy6n7csyHkEjZXGXnAQzKBwSBp
 - Okcash: PRcdBWFEKQatAidhK1idFnLnBdvu9mqjM3
 - Litecoin: M84U8YggaJ7T5E3TcqgcoF2BCTaxBMbCvN
