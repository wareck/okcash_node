#!/usr/bin/env python3
PIN=11 #11 led / 12 fan /#16 led+noctua
import RPi.GPIO as GPIO
from time import sleep
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(PIN, GPIO.OUT, initial=GPIO.LOW)
while True:
 GPIO.output(PIN, GPIO.HIGH)
 sleep(3)
 GPIO.output(PIN, GPIO.LOW)
 sleep(3)

