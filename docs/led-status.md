## Led status addon :
This script add a function to an external led.

Led will be on if your node is connected to network and staking (mining)

#### Shematic :
![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/led_status.png)

In this example, my led is connected to GND (pin6) and GPIO17 (pin11)

(you can choose any other GPIO, just don't forget to edit led-status.sh file and change the pin number)

![](https://raw.githubusercontent.com/wareck/okcash_node/master/docs/images/Raspberry-Pi-GPIO-Layout-Model-B-Plus-rotated.png)

#### Software :
If you want to edit options:
```shell
nano led-status.sh
```

then edit options :

**GPIO_PIN=11**     #GPIO Pin number to turn led on and off

**INVERT="NO"**     #If YES => led on when okcash crashed, NO => led on when okcash running


save 

then install addon with:
```shell
./led-status.sh
```
