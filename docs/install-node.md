## Raspberry Pi pre-build ##

Donwload **Raspbian OS lite** from https://www.raspberrypi.org/

Step 1 :**Then start your Raspberry Pi.**

Burn the sdcard with Raspberry os.

Start the Raspberry pi.

When logged into Raspberry start by an update upgrade :

    sudo apt-get update -y
    sudo apt-get upgrade -y
  
Then add essentials tools for starting :

    sudo apt-get install git -y
 
 Now configure your Raspberry :

    sudo raspi-config

adjust Hostname, Password , Timezone / Localisation 

Step 2 : ***reboot and login again***

    sudo reboot

Step 3 : ***clone github folder :***

	cd /home/pi
	git clone https://github.com/wareck/okcash_node_raspberry.git 
	cd /home/pi/okcash_node_raspberry

Step 4 : ***If you wants to use an USB key*** :

Plug you key in your raspberry pi now, (must be formated in EXT4 or F2FS)

Now prepare you raspberry to use usb key as okcash folder :

    
    nano usb.sh
    
edit the line 

	part_type=""  #f2fs or ext4
for my personal case : 

	part_type="f2fs"  #f2fs or ext4

save and exit.

	./usb.sh
				
Step 5 : ***reboot and login again***

    sudo reboot


## Build Okcash Node:
Launch build scrypt :

	cd /home/pi
	cd /home/pi/okcash_node_raspberry

You can edit options :

    nano build_node.sh
    

***Configuration options :***

***Bootstrap*** : YES or NO => download bootstrap.dat (speedup the first node start)

***CleanAfterInstall:*** YES or NO  => Remove install files after compilation (keep free space on sdcard)

***Raspi_optimize:*** YES or NO => Optimize Raspberry (give watchdog function and autostart Okcash)

***Website:*** YES or NO => Website frontend (small web page to check if everything is ok)

***Firewall:*** YES or NO => Enable firewall

***AutoStart:*** YES or NO => Enable autostart

***Banner:*** YES or NO =>Login banner

Save and exit nano...

Then start build:

    ./build_node.sh
	
**It will take between 1 or 2 hours to build okcashd, then raspberry will reboot.**

## Check :

You can check if everything works fine :

     okcashd getinfo

If you can see this king of screen, okcashd is running ...

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/getinfo.png)

***If you intalled the website frontend :***

open internet browser, use the Raspberry pi network address :

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/webgui.png)
