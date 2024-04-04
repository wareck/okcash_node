#!/bin/bash
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`

echo -e "\e[93mYahboom RGB Hat install $Version USB Tool\e[0m"
echo -e "Author : wareck@free.fr"

echo -e
sed -i -e 's/Yahboom="NO"/Yahboom="YES"/g' led-status.sh
sed -i -e 's/Yahboom="NO"/Yahboom="YES"/g' fan-control.sh

sleep 1
./led-status.sh
sleep 1
echo -e
./fan-control.sh
sleep 1
echo -e
./oled.sh
echo -e
sleep 1
sed -i -e 's/Yahboom="YES"/Yahboom="NO"/g' led-status.sh
sed -i -e 's/Yahboom="YES"/Yahboom="NO"/g' fan-control.sh
