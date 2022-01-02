#!/bin/bash
Version=`cat ../build_node.sh | grep -Po "(?<=Version=)([0-9]|\.)*(?=\s|$)"`
echo -e "\e[93mOkcash Headless Node builder $Version USB Tool\e[0m"
echo -e "Author : wareck@gmail.com"

format_type="f2fs"  # format type , can be f2fs or ext4

sda=""
sdb=""
sdc=""
sdd=""
sda=`ls -n /dev/disk/by-uuid/ | grep "sda" | awk '{print$9}'` >/dev/null
sdb=`ls -n /dev/disk/by-uuid/ | grep "sdb" | awk '{print$9}'` >/dev/null
sdc=`ls -n /dev/disk/by-uuid/ | grep "sdc" | awk '{print$9}'` >/dev/null
sdd=`ls -n /dev/disk/by-uuid/ | grep "sdd" | awk '{print$9}'` >/dev/null

function error_config {
echo -e "\nChoose your file filesystem first:"
echo "nano usb.sh"
echo "edit format_type=\"f2fs\" for f2fs or part_type=\"ext4\" for ext4 or part_type=\"vfat\" for vfat"
echo "save and run again ./usb.sh"
echo ""
exit
}

if [ -z $format_type ]; then error_config && exit ;fi
if ! [[ $format_type = "f2fs"  ||  $format_type = "ext4" ]]
then
	echo $format_type
	error_config
		if [ $format_type = "f2fs" ]
			then
				sudo apt-get install f2fs-tools -y
			fi
fi

if  [ -z $sda ];then sda_p=0; else sda_p=1;fi
if  [ -z $sdb ];then sdb_p=0; else sdb_p=1;fi
if  [ -z $sdc ];then sdc_p=0; else sdc_p=1;fi
if  [ -z $sdd ];then sdd_p=0; else sdd_p=1;fi
num=$(($sda_p + $sdb_p + $sdc_p + $sdd_p))
echo ""
if ! [ $num = 1 ]
then
	echo -e "More than one USB drive."
	echo -e "\e[33mCan't continue automaticaly\e[0m."
	echo -e "Please remove one USB drive or do it manualy..."
	echo -e
exit
else
	echo -e "Drive detected => \e[32mUUID=$sda\e[0m"
fi

if ! grep -q $sda /etc/fstab
then
if [ -f /tmp/tmp ]; then rm /tmp/tmp ;fi
cat <<'EOF'>> /tmp/tmp
#USB Drive for OkCash
UUID=SDA  /home/MYUSER/.okcash  FRMT    defaults,noatime  0       1
EOF
sed -i "s/SDA/$sda/" /tmp/tmp
sed -i "s/MYUSER/$USER/" /tmp/tmp
sed -i "s/FRMT/$format_type/" /tmp/tmp
sudo bash -c "cat /tmp/tmp >> /etc/fstab"
echo -e "\n\e[95mLines added to /etc/fstab:\e[0m"
tail -n +2 /tmp/tmp
echo -e ""
sleep 2
else
echo -e ""
echo -e "Drive is already defined in /etc/fstab."
echo -e ""
sleep 1
fi
if [ ! -d /home/$USER/.okcash ]
then
echo -e "\e[95mCreate directory:\e[0m"
echo -e "mkdir /home/$USER/.okcash"
mkdir /home/$USER/.okcash
sudo chown -R $USER /home/$USER/.okcash
sudo chmod -R 777 /home/$USER/.okcash
echo -e "Done."
echo -e
fi

echo -e "\e[95mMount drive:\e[0m"
if mountpoint -q "/home/$USER/.okcash"
then
echo -e "Already mounted."
echo -e "Done."
echo -e
else
sudo mount /home/$USER/.okcash
sudo chown -R $USER /home/$USER/.okcash
sudo chmod -R 777 /home/$USER/.okcash
echo "Done."
echo -e
fi

echo -e "\e[95mDirectory Check:\e[0m"
ls -w 2 /home/$USER/.okcash
echo -e "\nDone."
echo -e
