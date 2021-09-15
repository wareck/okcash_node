## Real Time Clock addon : ##
The RTC (real time clock) hardware addon.

If you let the system running without network after a while, raspberry internal clock drift.

The best is to use a small electronic addon (5$) for givin raspberry a RTC (based on chip DS1307)

![](https://raw.githubusercontent.com/wareck/rtc_rpi_addon/main/pics/rtc.png)
![](https://raw.githubusercontent.com/wareck/rtc_rpi_addon/main/pics/rtc_rpi.png)

How to install (software side) :
Script will install libraries, enable i2c connections.

    ./rtc.sh
    sudo reboot

After reboot, start again script (rtc init and synchronize):

    ./rtc.sh

Now internal clock and RTC clock were syncronized, and your RPI clock will never drift...
