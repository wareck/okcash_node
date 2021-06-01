## Node automatic fan control addon
This software and some cheap parts can easly add a fan and automatic control.

When the node work all the time, this could help to prevent overheat.

#### Shematic :
![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/fan_control.png)

You can use 2n2222 transistor or similar NPN transistor.

If you want's to use a 12volt fan (less expensive), simply add a DC/DC booster like this :

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/fan_control2.png)

I use GPIO 4 (PIN 7) for this schematics, but you can use any other one.

(don't forget to edit file like I explain in the next step)

![](https://raw.githubusercontent.com/wareck/okcash_node_raspberry/master/docs/images/Raspberry-Pi-GPIO-Layout-Model-B-Plus-rotated.png)


#### Software :

If you want to edit options:
```shell
nano fan-control.sh
```

Edit options :

**GPIO_PIN=4**     #GPIO Pin number to turn fan on and off

**Start_TEMP=49.0** #Start temperature in Celsius

**Gap_TEMP=5.0**  #Wait until the temperature is X degrees under the Max before shutting off


save , then install addon by:
```shell
./fan-control.sh
```

#### how it works ? :
Software check cpu temp each minutes.
If temp reach "Start_TEMP" fan start and works until cpu cool down Gap_TEMP
