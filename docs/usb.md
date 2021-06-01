## How to prepare an USB key:

**Step 1:**
plug you usb key

    dmesg
![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/usb/1.png)

identify your usb key, for me it's sda 

**Step 2:**

    sudo cfdisk /dev/sda

***be carefull, now everything you will do, will erase the usb key !***

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/usb/2.png)

do :

    Delete
    New partition
    Choose primary partition
    Write and accept (Y)
    Quit

**Step 3:**

The drive is ready to receive partiton format.

You have to choose if you want to use EXT4 or F2FS.

EXT4 and F2FS have very similar performance, but F2FS makes USB key live longer...

***If you choose EXT4:***

    sudo mkfs.ext4 /dev/sda
    
 ***If you choose F2FS:***

    sudo apt-get install f2fs-tools -y
    sudo mkfs.f2fs /dev/sda -f

**Step 4:**
UBS key is now ready to be used by okcash build script:

Go to okcash_node folder and edit usb.sh

    cd okcash_node
    nano usb.sh
    
change the line :
***part_type=""  #f2fs or ext4***

like for me :

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/usb/3.png)

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/usb/4.png)

save then :

    ./usb.sh

**Step 5:**

reboot
