#!/bin/bash
set -e
Version=6.8.0
Release=04/04/2024
author=wareck@free.fr

#Okcash headless RPI Working (sync enable, staking enable)

#download external config:
source config.txt

function config_check {
Okcash_DEV=${Okcash_DEV^^}
Bootstrap=${Bootstrap^^}
Raspi_optimize=${Raspi_optimize^^}
Website=${Website^^}
Website_daemon=${Website_daemon^^}
Firewall=${Firewall^^}
Ipv6=${Ipv6^^}
Banner=${Banner^^}
AutoStart=${AutoStart^^}
Reboot=${Reboot^^}

if ! [[ $Website_daemon = "APACHE"  || $Website_daemon = "LIGHTTPD" || $Website_daemon = "NGINX" ]];then echo "Error configuration Web_daemon" & exit ;fi
if ! [[ $Bootstrap = "YES" || $Bootstrap = "NO" ]];then echo "Error configuration Bootstrap" & exit ;fi
if [ -f /dev/root ]
then
SOC=`df | grep /dev/root | awk '{print $4'}`
else
SOC=`df / | grep "/" | awk {'print $4'}`
fi
if [ -f /boot/dietpi.txt ]
then
LSB=$(cat /etc/debian_version)
img_v="\e[93mDietpi\e[0m"
DietPi_="YES"
else
LSB=$(cat /etc/debian_version)
OSV=$(sed 's/\..*//' /etc/debian_version)
DietPi_="NO"
case $OSV in
8 | 9 )
echo -e "Obsolete raspberry image. please use a newer one"
exit 0
;;
10)
img_v="Buster"
OpenSSL_v="1.0.2u"
Boost_v="1_67_0"
DB_v="4.8.30.NC"
Miniupnpc_v="2.2.3"
;;
11)
img_v="Bullseye"
OpenSSL_v="3.0.2"
Boost_v="1_74_0"
DB_v="4.8.30.NC"
Miniupnpc_v="2.2.3"
;;
12)
img_v="Bookworm"
Boost_v="1_74_0"
OpenSSL_v="3.0.2"
DB_v="4.8.30.NC"
Miniupnpc_v="2.2.3"
;;
*)
echo -e "\e[38;5;166mUnknown system, please use Raspberry Stretch , Jessie, Buster or Bullseye image...\e[0m"
exit 0
;;
esac
fi
F64=$(getconf LONG_BIT)
if [ $F64 = 64 ]
then
F64="YES"
fi
if [ -f /proc/device-tree/model ]
then
ident=$(tr -d '\0' < /proc/device-tree/model)
else
ident=""
img_v="Unknown"
fi
}

### Main Code ###
# check size of card:
MyUser=$USER
MyDir=$PWD
Dw=0
echo $MyUser>/tmp/node_user
echo -e "\e[93mOkcash Headless Node builder v$Version ($Release)\e[0m"
echo -e "Author : wareck@gmail.com"
config_check
echo -e "\n\e[97mConfiguration:\e[0m"
echo -e "--------------"
echo -e -n "Download Bootstrap.dat    : "; if [ $Bootstrap = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Raspberry Optimisation    : "; if [ $Raspi_optimize = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Node message banner       : "; if [ $Banner = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Okcash autostart at boot  : "; if [ $AutoStart = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Website Frontend          : "; if [ $Website = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Firewall enable           : "; if [ $Firewall = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
echo -e -n "Reboot when finish build  : "; if [ $Reboot = "YES" ];then echo -e "[\e[92m YES \e[0m]"; else echo -e "[\e[91m NO  \e[0m]";fi
if [ $Website = "YES" ] && [ ! $Website_port = "80" ]
then
echo -e -n "Html port number $Website_port     : \e[38;5;0166mHidden \e[0m"
else
echo -e -n "Website engine            :  $Website_daemon"
fi
sleep 1

if [ $Okcash_DEV = "YES" ]
then
wget -q -c https://raw.githubusercontent.com/okcashpro/okcash/master/okcash.pro -O /tmp/okcash.pro
OKcash_v="`cat /tmp/okcash.pro | grep VERSION | awk '{print$3}' | awk '{print $1}' | grep -v '{'`"
rm /tmp/okcash.pro
Comment="(Source from github)"
else
OKcash_v=7.0.0.0-spacemonkey
Comment="(Release)"
fi
echo -e "\n\n\e[97mSoftware Release:\e[0m"
echo -e "-----------------"
echo $ident
echo -e "Raspbian Image            : v$LSB ($img_v)"
if [ $F64 = "YES" ]
then
echo -e "Mode                      : 64 bits"
fi
echo -e "Boost                     : $Boost_v"
echo -e "OpenSSL                   : $OpenSSL_v"
echo -e "DB Berkeley               : $DB_v"
echo -e "Miniupnpc                 : $Miniupnpc_v"
echo -e "Okcash                    : $OKcash_v $Comment"
sleep 1

if [ $Bootstrap = "YES" ]
then
echo -e "\n\e[97mBootstrap:\e[0m"
echo -e "----------"
bt_version="`curl -s http://wareck.free.fr/crypto/okcash/bootstrap/bootstrap_v.txt | awk 'NR==1 {print$3;exit}'`"
bt_parts="`curl -s http://wareck.free.fr/crypto/okcash/bootstrap/bootstrap_v.txt | awk 'NR==2 {print$2; exit}'`"
bt_size="`curl -s http://wareck.free.fr/crypto/okcash/bootstrap/bootstrap_v.txt | awk 'NR==3 {print$3; exit}'`"
echo -e "Boostrap.dat              : $bt_version ($bt_parts files)"
fi
if [ $Bootstrap = "YES" ] && ! [ -f .pass ]
then
if [ $SOC -le 37 ]
then
echo ""
echo "Due to bootstrap file size increase a lot last month"
echo "Your sdcard is now too small to keep source code."
echo "Option KeepSourceAfterInstall was automaticaly set to NO"
echo "Use a bigger scdard to keep sourcefiles on card after compilation"
echo ""
fi
fi

if ps -ef | grep -v grep | grep okcashd >/dev/null
then
echo -e "\n\e[38;5;166mOKcash daemon is working => shutdown and will restart after install...\e[0m"
okcashd stop | true
sudo /etc/init.d/cron stop >/dev/null
sudo killall -9 okcashd | true
Dw=1
sudo /etc/init.d/cron stop 2>/dev/null || true
if [ "`systemctl is-active watchdog.service`" = "active" ]
then
echo -e "\n\e[93mStopping okcashd watchdog:\e[0m"
sudo systemctl stop watchdog >/dev/null
echo -e "Done."
fi
fi
sleep 1

function prereq_ {
echo -e "\n\e[95mSystem Check:\e[0m"
update_me=0
ntp_i=""
pv_i=""
gcc_i=""
xz_i=""
p7zip_i=""
zstd_i=""
pwgen_i=""
swap_i=""
xxd=""
echo -e -n "Check PV                  : "
if ! [ -x "$(command -v pv)" ];then echo -e "[\e[91m NO  \e[0m]" && pv_i="pv" && update_me=1;else echo -e "[\e[92m YES \e[0m]";fi
if [ $DietPi_ = "NO" ]
then
echo -e -n "Check NTPD                : "
if ! [ -x "$(command -v ntpd)" ];then echo -e "[\e[91m NO  \e[0m]" && ntp_i="ntp" && update_me=1;else echo -e "[\e[92m YES \e[0m]";fi
fi
echo -e -n "Check P7ZIP               : "
if ! [ -x "$(command -v 7z)" ];then echo -e "[\e[91m NO  \e[0m]" && p7zip_i="p7zip-full libbz2-dev liblzma-dev libzip-dev zlib1g-dev" && update_me=1;else echo -e "[\e[92m YES \e[0m]";fi
echo -e -n "Check PWGEN               : "
if ! [ -x "$(command -v pwgen)" ];then echo -e "[\e[91m NO  \e[0m]" && pwgen_i="pwgen" && update_me=1;else echo -e "[\e[92m YES \e[0m]";fi
if ! [ -x "$(command -v xxd)" ]; then xxd_i="xxd" && update_me=1;fi
if ! [ -x "$(command -v htop)" ];then htop_i="htop" && update_me=1;fi
if ! [[ -f .pass  || -x "$(command -v dphys-swapfile)" ]];then swap_i="dphys-swapfile" && update_me=1 ;fi
echo -e -n "Check MegaDownload        : "
if ! [ -x "$(command -v megadown)" ]
then
echo -e "[\e[91m NO  \e[0m]"
curl -LJO --silent https://github.com/wareck/megadown/releases/download/v1.0/megadown.tar.bz2
tar xfj megadown.tar.bz2
sudo mv megadown /usr/local/bin
rm megadown.tar.bz2
else
echo -e "[\e[92m YES \e[0m]"
fi

if [ $update_me = 1 ]
then
echo -e "\n\e[95mRaspberry update:\e[0m"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install aptitude -y
if [ img_v="Bookworm" ]
then
python_dev_i="python-dev-is-python3"
else
python_dev_i="python-dev"
fi
sudo apt install pv git build-essential $python_dev_i $htop_i $ntp_i $pwgen_i $p7zip_i $swap_i $xxd_i $zstd_i -y
sudo sed -i -e "s/# set const/set const/g" /etc/nanorc
fi
sleep 1

#if [ $img_v = "Bookworm" ] && [ $F64 = "YES" ]
#then
#echo -e "\n\e[95mInstall gcc-10.2.0 ToolChain:\e[0m"
#if [ ! -d gcc-10.2.0 ]
#then
#curl http://wareck.free.fr/crypto/okcash/sources/gcc-10.2.0.tar.xz | tar -xJ
#fi
#sudo cp -r -v gcc-10.2.0/* /usr/local/
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/aarch64-unknown-linux-gnu-gcc-10.2.0 10 >/dev/null
#sudo update-alternatives --install /usr/bin/g++ g++ /usr/local/bin/aarch64-unknown-linux-gnu-g++ 10 >/dev/null
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 >/dev/null
#sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12 >/dev/null
#sleep 2
#sudo update-alternatives --set gcc "/usr/local/bin/aarch64-unknown-linux-gnu-gcc-10.2.0" >/dev/null
#sudo update-alternatives --set g++ "/usr/local/bin/aarch64-unknown-linux-gnu-g++" >/dev/null
#fi

}

function Download_Extract_ {
echo -e "\n\e[95mDownload/Extract Boost Library:\e[0m"
if ! [ -d $MyDir/boost_$Boost_v ]
then
	wget -c -q --show-progress http://wareck.free.fr/crypto/okcash/sources/boost_$Boost_v.tar.xz
	tar xfJ boost_$Boost_v.tar.xz --checkpoint=.500
fi
echo -e "Done."

echo -e "\n\e[95mDownload/Extract OpenSSL Library:\e[0m"
if ! [ -d $MyDir/openssl-$OpenSSL_v ]
then
	wget -c -q --show-progress http://wareck.free.fr/crypto/okcash/sources/openssl-$OpenSSL_v.tar.xz
	tar xfJ openssl-$OpenSSL_v.tar.xz --checkpoint=.100
fi
echo -e "Done."

echo -e "\n\e[95mDonwload/Extract Miniupnpc Library:\e[0m"
if ! [ -d $MyDir/miniupnpc-$Miniupnpc_v ]
then
	wget -c -q --show-progress http://wareck.free.fr/crypto/okcash/sources/miniupnpc-$Miniupnpc_v.tar.xz
	tar xfJ miniupnpc-$Miniupnpc_v.tar.xz --checkpoint=.1
fi
echo -e "Done."

echo -e "\n\e[95mDownload/Extract db-4.8.30.NC Library:\e[0m"
if ! [ -d $MyDir/db-$DB_v ]
then
	wget -c -q --show-progress http://wareck.free.fr/crypto/okcash/sources/db-$DB_v.tar.xz
	tar xfJ db-$DB_v.tar.xz --checkpoint=.100
fi
echo -e "Done."

echo -e "\n\e[95mDownload OkCash $OKcash_v Source Code:\e[0m"
if ! [ -d $MyDir/okcash ]
then
case $Okcash_DEV in
NO)
	git clone -n https://github.com/okcashpro/okcash.git
	cd okcash
	git reset --hard f252160e2ed49956d9406585c4ee34e775397ceb #v7
	cd ..
	;;
YES)
	git clone https://github.com/okcashpro/okcash.git
	;;
*)	echo "Error"
	;;
esac
fi
echo -e "Done."
}

function Build_Dependencies_ {
echo -e "\n\e[95mBuild Openssl $OpenSSL_v.:\e[0m"
if [ $F64 = "YES" ]
then
arch="linux-aarch64"
else
arch="linux-armv4"
fi

cd openssl-$OpenSSL_v

case $Okcash_DEV in
NO)
	./Configure no-zlib no-shared no-dso no-krb5 no-camellia no-capieng no-cast no-dtls1 no-gost no-gmp no-heartbeats no-idea no-jpake \
	no-md2 no-mdc2 no-rc5 no-rdrand no-rfc3779 no-rsax no-sctp no-seed no-sha0 no-static_engine no-whirlpool no-rc2 no-rc4 no-ssl2 no-ssl3 $arch
	make depend
	make -j$(nproc)
	;;
YES)
	./Configure $arch
	make depend
	make -j$(nproc)
	sudo make install
	;;
*)	echo "Error"
	;;
esac
cd ..

echo -e "\n\e[95mBuild DB-$DB_v:\e[0m"
if [ -f /usr/share/man/man3/miniupnpc.3.gz ]; then sudo rm /usr/share/man/man3/miniupnpc.3.gz; fi
cd db-$DB_v
cd build_unix
../dist/configure --enable-cxx --disable-shared --with-pic
make -j$(nproc)
sudo make install
sudo ln -s /usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.so /usr/lib/ || true
cd .. && cd ..

echo -e "\n\e[95mBuild Boost $Boost_v:\e[0m"
cd boost_$Boost_v
./bootstrap.sh
sudo ./b2 --with-chrono --with-filesystem --with-program_options --with-system --with-thread --with-timer --with-test \
toolset=gcc variant=release link=static threading=multi runtime-link=static install
cd ..

echo -e "\n\e[95mBuild miniupnpc $Miniupnpc_v:\e[0m"
cd miniupnpc-$Miniupnpc_v
make -j$(nproc)
sudo make install
cd ..

echo
echo -e "\n\e[93mAll dependencies were builded...\e[0m"
if ! [ -f .pass ]
then
touch .pass >/dev/null
fi
rm *.tar.xz | true
}

function Build_Okcash_ {
echo -e "\n\e[95mBuild OkCash:\e[0m"
if  ps -ef | grep -v grep | grep okcashd >/dev/null
then
sudo bash -c 'sudo /etc/init.d/cron stop'
killall -9 okcashd
sleep 1
fi
cd okcash
cd src

if ! [ -f makefile.arm.patch ]
then
cp $MyDir/files/makefile.arm.patch .
echo -e "\e[97mPatching makefile.arm \e[0m"
patch -p0 <makefile.arm.patch
fi

cd leveldb
make -j$(nproc)
make -j$(nproc) libmemenv.a
cd ..
Totalmem=$(awk '{ printf "%.1f", $2/1024/1024 ; exit}' /proc/meminfo | cut -d. -f1 )
if [ $Totalmem -gt 2 ] # low memory Raspberry reduce GCC speed and memory use, else normal compilation
then
Flag="--param ggc-min-expand=1 --param ggc-min-heapsize=32768"
else
Flag=""
fi
if [ $F64 = "YES" ];then a=2;else a="$(nproc)";fi
make -j$a -w -f makefile.arm CXXFLAGS="$Flag -fcommon -w" \
OPENSSL_LIB_PATH=$MyDir/openssl-$OpenSSL_v OPENSSL_INCLUDE_PATH=$MyDir/openssl-$OpenSSL_v/include BDB_INCLUDE_PATH=/usr/local/BerkeleyDB.4.8/include/ \
BDB_LIB_PATH=/usr/local/BerkeleyDB.4.8/lib BOOST_LIB_PATH=/usr/local/lib/ BOOST_INCLUDE_PATH=/usr/local/include/boost/ \
MINIUPNPC_INCLUDE_PATH=/usr/include/miniupnpc MINIUPNPC_LIB_PATH=/usr/lib/ -k
sudo cp okcashd /usr/local/bin ||true
sudo strip /usr/local/bin/okcashd ||true
}

function conf_ {
echo -e "\n\e[95mInstall okcash.conf:\e[0m"
if ! [ -f /home/$MyUser/.okcash/okcash.conf ]
then
if ! [ -d /home/$MyUser/.okcash/ ]; then mkdir /home/$MyUser/.okcash/ ; fi
touch /home/$MyUser/.okcash/okcash.conf
cat <<'EOF'>> /home/$MyUser/.okcash/okcash.conf
#Daemon and listen ON/OFF
daemon=1
listen=1
staking=1
enableaccounts=1
maxconnections=15

#Connection User and Password
rpcuser=user
rpcpassword=password

#Authorized IPs
rpcallowip=127.0.0.1
rpcport=drpc_port
port=dudp_port

#write the location for this blockchain below if not on standard directory
#datadir=/home/USER/.okcash

#Add extra Nodes
addnode=104.229.10.238
addnode=108.160.119.104
addnode=108.5.241.97
addnode=13.209.60.161
addnode=139.47.17.53
addnode=142.132.199.25
addnode=146.70.112.108
addnode=146.70.112.188
addnode=148.59.149.52
addnode=154.56.136.18
addnode=159.196.219.68
addnode=162.252.240.130
addnode=171.33.234.206
addnode=171.33.234.222
addnode=177.149.118.79
addnode=178.249.211.136
addnode=82.65.226.217
addnode=86.106.2.111
addnode=86.106.2.162
addnode=91.246.66.175
addnode=91.51.100.183
EOF
rpcu=$(pwgen -ncsB 18 1) #gen random user
rpcp=$(pwgen -ncsB 18 1) #gen random password
sed -i -e "s/rpcuser=user/rpcuser=$rpcu/g" /home/$MyUser/.okcash/okcash.conf
sed -i -e "s/rpcpassword=password/rpcpassword=$rpcp/g" /home/$MyUser/.okcash/okcash.conf
sed -i -e "s/drpc_port/$drpc_port/g" /home/$MyUser/.okcash/okcash.conf
sed -i -e "s/dudp_port/$dudp_port/g" /home/$MyUser/.okcash/okcash.conf
else
echo -e "File okcash.conf already setup."
fi
echo "Done."
}

function Bootstrap_ {
badsum=0

echo -e "\n\e[95mDownload Bootstrap $bt_version ( $bt_parts x $bt_size Mo ):\e[0m"
folder="bootstrap"
cd /home/$MyUser
LN=5 #Start line number
for i in `seq 1 $bt_parts`;
do
bootstrap_address=$(curl -s http://wareck.free.fr/crypto/okcash/bootstrap/bootstrap_v.txt | head -$LN | tail -1)
megadown $bootstrap_address
LN=$((LN+1))
done
echo -e ""
for i in `seq -w 001 $bt_parts`;
do
wget -c -q --show-progress http://wareck.free.fr/crypto/okcash/bootstrap/bootstrap.$i.md5
done
echo -e "Done."

echo -e "\n\e[95mBootstrap checksum test:\e[0m"
for i in `seq -w 001 $bt_parts`;
do
echo -e -n "Bootstrap.$i.md5 md5sum Test: " && if md5sum --status -c bootstrap.$i.md5; then echo -e "[\e[92m OK \e[0m]"; else echo -e "[\e[91m NO \e[0m]" && badsum=1 ;fi
if [ $badsum = "1" ]
then
echo -e "\e[38;5;166mBootstrap.7z error !\e[0m"
echo -e "\e[38;5;166mMaybe file damaged or not fully download\e[0m"
echo -e "\e[38;5;166mRestart build_node to try again !\e[0m"
exit
fi
done

rm bootstrap.*.md5

if [ -f ~/.okcash/blk0001.dat ]
then
echo -e "\n\e[95mClean old data before extract:\e[0m"
rm -r -f ~/.okcash/blk0001.dat
rm -r -f ~/.okcash/database
rm -r -f ~/.okcash/txleveldb
rm -r -f ~/.okcash/peers.dat
rm -r -f ~/.okcash/smsg*
rm -r -f okcashd.pid
echo "Done."
fi

echo -e "\n\e[95mExtract bootstrap.tar.xz:\e[0m"
7za x bootstrap.7z.001
sleep 3
rm bootstrap.7z.*
echo -e "Done."
}

function clean_after_install_ {
echo -e "\n\e[95mCleaning folders:\e[0m"
cd $MyDir
rm boost_$Boost_v.tar.xz || true
rm openssl-$OpenSSL_v.tar.xz ||true
rm miniupnpc-$Miniupnpc_v.tar.xz || true
rm db-4.8.30.NC.tar.xz || true
if [ -f /home/$MyUser/bootstrap.tar.xz ]; then rm /home/$MyUser/bootstrap.tar.xz || true; fi
echo -e "Remove openssl-1.0.2g"
sudo rm -r -f openssl-$OpenSSL_v  || true
echo -e "Remove miniupnpc-$Miniupnpc_v."
sudo rm -r -f miniupnpc-$Miniupnpc_v || true
echo -e "Remove db-4.8.30.NC"
sudo rm -r -f db-4.8.30.NC || true
echo -e "Remove db-4.8.30"
sudo rm -r -f db-4.8.30 || true
echo -e "Remove boost_$Boost_v"
sudo rm -r -f boost_$Boost_v || true
if [ -d gcc-10.2.0 ];then rm -r gcc-10.2.0 >/dev/null ;fi
if [ -f .pass ]; then rm .pass >/dev/null ;fi
echo "Done."
}

if ! [ -d okcash ]
then
if [ -f .pass ]; then rm .pass >/dev/null ; fi ||true #no okcash source => rebuild dependencies and okcash
fi

function install_website_ {
echo -e "\n\e[95mWebsite Frontend installation:\e[0m"
if [ $Website_daemon = "APACHE" ]
then
sudo apt-get install apache2 -y >/dev/null
OSV=$(sed 's/\..*//' /etc/debian_version)
case $OSV in
10)
sudo apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-gd php7.3-curl php7.3-zip php7.3-xml libapache2-mod-php7.3 -y >/dev/null;;
11)
sudo apt-get install php7.4-fpm php7.4-mbstring php7.4-mysql php7.4-gd php7.4-curl php7.4-zip php7.4-xml libapache2-mod-php7.4 -y >/dev/null;;
12)
sudo apt install -y apt-transport-https lsb-release ca-certificates wget -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install php7.4-fpm php7.4-mbstring php7.4-mysql php7.4-gd php7.4-curl php7.4-zip php7.4-xml libapache2-mod-php7.4 -y  >/dev/null
sudo a2enmod rewrite >/dev/null
sudo a2enmod php7.4 >/dev/null
;;
esac
fi

if [ $Website_daemon = "LIGHTTPD" ]
then
sudo apt-get install lighttpd -y >/dev/null
OSV=$(sed 's/\..*//' /etc/debian_version)
case $OSV in
10)
sudo apt-get install php7.3-fpm php7.3-curl php7.3-zip php7.3-xml -y >/dev/null;;
11)
sudo apt-get install php7.4-fpm php7.4-curl php7.4-zip php7.4-xml -y >/dev/null;;
12)
sudo apt install -y apt-transport-https lsb-release ca-certificates wget -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install php7.4-fpm php7.4-curl php7.4-zip php7.4-xml -y >/dev/null;;
esac
fi

if [ $Website_daemon = "NGINX" ]
then
sudo apt-get install nginx -y
OSV=$(sed 's/\..*//' /etc/debian_version)
case $OSV in
10)
sudo apt-get install php7.3-fpm php7.3-curl php7.3-zip -y >/dev/null;;
11)
sudo apt-get install php7.4-fpm php7.4-curl php7.4-zip -y >/dev/null;;
12)
sudo apt install -y apt-transport-https lsb-release ca-certificates wget -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
sudo apt-get install php7.4-fpm php7.4-curl php7.4-zip -y >/dev/null;;
esac
fi

cd /var/www/
if ! [ -f /var/www/node_status/php/config.php ]
then
        sudo bash -c 'git clone https://github.com/wareck/okcash-node-frontend.git node_status'
        sudo bash -c 'sudo cp /var/www/node_status/php/config.sample.php /var/www/node_status/php/config.php'
	param1=`cat /home/$MyUser/.okcash/okcash.conf  | grep "rpcuser=" | awk -F "=" '{print$2}'`
	param2=`cat /home/$MyUser/.okcash/okcash.conf  | grep "rpcpassword=" | awk -F "=" '{print$2}'`
	cat /var/www/node_status/php/config.php >> /tmp/config.php
	sed -i -e "s/rpcuser/$param1/g" /tmp/config.php
	sed -i -e "s/rpcpass/$param2/g" /tmp/config.php
	sed -i -e "s/myport/$drpc_port/g" /tmp/config.php
	if  grep "USB Drive for OkCash" /etc/fstab >/dev/null
	then
	sed -i -e "s/DRV/\/home\/$MyUser\/.okcash/g" /tmp/config.php
	else
	sed -i -e "s/DRV/\//g" /tmp/config.php
	fi
	sudo bash -c 'sudo mv /tmp/config.php /var/www/node_status/php/config.php'
fi

if [ $Website_daemon = "APACHE" ]
then
	if [ ! -f /etc/apache2/sites-enabled/000-default.conf.old ]
	then
        sudo bash -c 'sudo mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.old'
	fi
	if [ ! -f /etc/apache2/sites-enabled/001-node_status.conf ]
	then
cat <<'EOF'>> /tmp/001-node_status.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/node_status
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
        sed -i -e "s/80/$Website_port/g" /tmp/001-node_status.conf
        sudo cp /tmp/001-node_status.conf /etc/apache2/sites-enabled/001-node_status.conf
	fi
        cd /home/$MyUser
fi

if [ $Website_daemon = "LIGHTTPD" ]
then
	if ! [ -f /etc/lighttpd/lighttpd.conf.old ]
	then
	sudo cp /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.old
	fi
cp /etc/lighttpd/lighttpd.conf /home/pi/
sed -i -e "s/html/node_status/g" /home/pi/lighttpd.conf
sed -i -e "s/server.port                 = 80/server.port                 = /g" /home/pi/lighttpd.conf
sed -i -e "s/server.port                 = /server.port                 = $Website_port/g" /home/pi/lighttpd.conf
sudo cp /home/pi/lighttpd.conf /etc/lighttpd/lighttpd.conf
cat <<'EOF'>> /tmp/15-fastcgi-php.conf
# -*- depends: fastcgi -*-
# /usr/share/doc/lighttpd/fastcgi.txt.gz
# http://redmine.lighttpd.net/projects/lighttpd/wiki/Docs:ConfigurationOptions#mod_fastcgi-fastcgi

## Start an FastCGI server for php (needs the php5-cgi package)
fastcgi.server += ( ".php" =>
        ((
                "socket" => "/var/run/php/php7.4-fpm.sock",
                "broken-scriptfilename" => "enable"
        ))
)
EOF
sudo cp /tmp/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo rm /tmp/15-fastcgi-php.conf
sudo lighttpd-enable-mod fastcgi fastcgi-php rewrite | true
fi

if [ $Website_daemon = "NGINX" ]
then
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
cat <<'EOF'>> /tmp/ng_default
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  root /var/www/node_status;
  index index.php index.html index.htm index.nginx-debian.html;
  server_name _;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
  }
  location ~ /\.ht {
    deny all;
  }
}
EOF
if [ $OSV = "10" ];then sed -i -e "s/php7.4-fpm.sock/php7.3-fpm.sock/g" /tmp/ng_default;fi
sed -i -e "s/listen 80/listen $Website_port/g" /tmp/ng_default
sudo cp /tmp/ng_default /etc/nginx/sites-available/default
sudo rm /tmp/ng_default
if [ $OSV = "10" ];then sudo cp /etc/php/7.3/fpm/php.ini . ;fi
if [ $OSV = "11" ];then sudo cp /etc/php/7.4/fpm/php.ini . ;fi
if [ $OSV = "12" ];then sudo cp /etc/php/7.4/fpm/php.ini . ;fi
sudo sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" php.ini
if [ $OSV = "10" ];then sudo cp php.ini /etc/php/7.3/fpm/php.ini ;fi
if [ $OSV = "11" ];then sudo cp php.ini /etc/php/7.4/fpm/php.ini ;fi
if [ $OSV = "12" ];then sudo cp php.ini /etc/php/7.4/fpm/php.ini ;fi
sudo rm php.ini
fi

if  ! grep "curl -Ssk http://127.0.0.1/stats.php" /etc/crontab >/dev/null
then
sudo bash -c 'echo "" > /dev/null >>/etc/crontab | sudo -s'
sudo bash -c 'echo "#Okcash frontend website" > /dev/null >>/etc/crontab | sudo -s'
sudo bash -c 'form=$(cat "/tmp/node_user") && echo "*/5 *  *   *   *  $form curl -Ssk http://127.0.0.1/stats.php > /dev/null" >>/etc/crontab | sudo -s'
sudo bash -c 'form=$(cat "/tmp/node_user") && echo "*/5 *  *   *   *  $form curl -Ssk http://127.0.0.1/peercount.php > /dev/null" >>/etc/crontab | sudo -s'
fi
if [ $Website_daemon = "APACHE" ];then sudo /etc/init.d/apache2 restart >/dev/null;fi
if [ $Website_daemon = "LIGHTTPD" ];then sudo /etc/init.d/lighttpd restart >/dev/null;fi
if [ $Website_daemon = "NGINX" ];then sudo /etc/init.d/nginx restart >/dev/null;fi
echo -e "Done."
}

function Raspberry-optimisation_ {
echo -e "\n\e[95mRaspberry optimisation:"
echo -e -n "\e[97mWatchDog and Autostart: \e[0m"
if ! [ $F64 = "YES" ]
then
sudo apt-get install watchdog chkconfig -y >/dev/null
sudo chkconfig watchdog on >/dev/null
sudo /etc/init.d/watchdog start >/dev/null
sudo update-rc.d watchdog enable >/dev/null
else
sudo apt-get install watchdog -y >/dev/null
sudo /etc/init.d/watchdog start >/dev/null
sudo update-rc.d watchdog enable >/dev/null
fi

if ! [ -f /home/$MyUser/scripts/watchdog_okcash.sh ]
then
if ! [ -d /home/$MyUser/scripts ];then mkdir /home/$MyUser/scripts;fi
cat <<'EOF'>> /home/$MyUser/scripts/watchdog_okcash.sh
#!/bin/bash
if ps -ef | grep -v grep | grep okcashd >/dev/null
then
exit 0
else
okcashd --printtoconsole
exit 0
fi
EOF
fi
chmod +x /home/$MyUser/scripts/watchdog_okcash.sh
echo -e "Done."

echo -e -n "\e[97mEnabling/tunning Watchdog: \e[0m"
sudo bash -c 'sed -i -e "s/#watchdog-device/watchdog-device/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#interval             = 1/interval            = 4/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#max-load-1              = 24/max-load-1              = 24/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#max-load-5              = 18/watchdog-timeout = 15/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#RuntimeWatchdogSec=0/RuntimeWatchdogSec=14/g" /etc/systemd/system.conf'
if ! [ -f /etc/modprobe.d/bcm2835_wdt.conf ]
then
sudo bash -c 'touch /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-130 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-131 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "bcm2835_wdt" >>/etc/modules'
fi
echo -e "Done."

echo -e -n "\e[97mWatchdog.sh & crontab: \e[0m"
if  ! grep "watchdog_okcash.sh" /etc/crontab >/dev/null
then
sudo bash -c 'echo "" >>/etc/crontab | sudo -s'
sudo bash -c 'echo "#okcash watchdog" >>/etc/crontab | sudo -s'
sudo bash -c 'form=$(cat "/tmp/node_user") && echo "*/15  * * * * $form /home/$form/scripts/watchdog_okcash.sh" >>/etc/crontab'
fi
echo "Done."

if  [ $DietPi_ = "NO" ]
then
echo -e -n "\e[97mDisable Blueutooth: \e[0m"
	if ! grep "dtoverlay=pi3-disable-bt" /boot/config.txt >/dev/null
	then
	sudo bash -c 'echo "" >>/boot/config.txt'
	sudo bash -c 'echo "# Disable internal BT" >>/boot/config.txt'
	sudo bash -c 'echo "dtoverlay=pi3-disable-bt" >>/boot/config.txt'
	sudo systemctl disable hciuart >/dev/null
	sleep 1
	fi
echo -e "Done."
fi

echo -e -n "\e[97mDisable Audio: \e[0m"
if grep "dtparam=audio=on" /boot/config.txt >/dev/null
	then
	sudo bash -c 'sed -i -e "s/dtparam=audio=on/dtparam=audio=off/g" /boot/config.txt'
fi
echo -e "Done."

echo -e -n "\e[97mDisable Console blank: \e[0m"
if ! grep "consoleblank=0" /boot/cmdline.txt >/dev/null
	then
	sudo bash -c 'sed -i -e "s/rootwait/rootwait consoleblank=0/g" /boot/cmdline.txt'
fi

echo -e "Done."

#echo -e -n "\e[97mDisable wifi power saving: \e[0m"
#if ! grep "#Disable wifi power saving" /etc/rc.local >/dev/null
#        then
#                sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
#                sudo bash -c 'echo "#Disable wifi power saving" >>/etc/rc.local'
#                sudo bash -c 'echo "/sbin/iwconfig wlan0 power off" >>/etc/rc.local'
#                sudo bash -c 'echo "exit 0" >>/etc/rc.local'
#fi
#echo -e "Done."

if [ $Ipv6 = "NO" ]
then
echo -e -n "\e[97mDisable ipv6: \e[0m"
if ! grep "#Disable ipv6" /etc/sysctl.conf  >/dev/null
then
cp /etc/sysctl.conf /tmp
cat <<'EOF'>>  /tmp/sysctl.conf
#Disable ipv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv6.conf.eth0.disable_ipv6 = 1
EOF
sudo cp /tmp/sysctl.conf /etc/sysctl.conf
fi
echo -e "Done."
fi
}

function mkswap {
if [ $DietPi_ = "NO" ]
then
echo -e "\n\e[95mRaspberry optimisation\e[97m Disable Swap:\e[0m"
sudo dphys-swapfile swapoff > /dev/null
sudo dphys-swapfile uninstall > /dev/null
sudo systemctl disable dphys-swapfile > /dev/null
if [ -f /var/swap ]; then sudo rm /var/swap ; fi
sudo apt-get purge -y dphys-swapfile > /dev/null
echo -e "Done."
fi
}

function auto_start_ {
echo -e "\n\e[95mOkcash autostart: \e[0m"
if ! [ -f /etc/rc.local ]
then
cat <<'EOF'>>/tmp/rc.local
#!/bin/bash
exit 0
EOF
sudo cp /tmp/rc.local /etc/
sudo chmod +x /etc/rc.local
sudo systemctl disable rc-local
sudo systemctl disable rc.local
if ! [ -f /lib/systemd/system/rc-local.service ]
then
cat <<'EOF'>> /tmp/rc-local.service
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

# This unit gets pulled automatically into multi-user.target by
# systemd-rc-local-generator if /etc/rc.local is executable.
[Unit]
Description=/etc/rc.local Compatibility
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
EOF
sudo cp /tmp/rc-local.service /lib/systemd/system/rc-local.service
sudo systemctl daemon-reload
fi
else
if ! grep "#OKcash Node Start" /etc/rc.local >/dev/null
	then
		sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
		sudo bash -c 'echo "#OKcash Node Start" >>/etc/rc.local'
		sudo bash -c 'form=$(cat "/tmp/node_user") && echo -e "su - $form -c \x27okcashd --printtoconsole\x27" >>/etc/rc.local'
		sudo bash -c 'echo "exit 0" >>/etc/rc.local'
	fi
fi
echo -e "Done."
}

function banner_ {
if [ $DietPi_ = "NO" ]
then
echo -e "\n\e[95mInstall banner message:\e[0m"
ident=$(tr -d '\0' </proc/device-tree/model)
if [ -f /tmp/motd ]; then rm /tmp/motd ;fi
cat <<EOF>> /tmp/motd
 _____       _
|   | |___ _| |___
| | | | . | . | -_|
|_|___|___|___|___|

 Okcash node v$Version

EOF
sudo bash -c 'mv /tmp/motd /etc/motd | sudo -s'
if grep "raspberrypi" /etc/hostname >/dev/null;then sudo sed -i -e "s/raspberrypi/Node/g" /etc/hostname ;fi
if grep "raspberrypi" /etc/hosts >/dev/null;then sudo sed -i -e "s/raspberrypi/Node/g" /etc/hosts;fi
echo -e "Done."
fi
}

function Firewall_ {
echo -e "\n\e[95mFirewall setup :\e[0m"
sudo apt-get -y install ufw
if [ $Website = "YES" ]
then
if [ $Website_daemon = "APACHE" ]
then
echo "Hidding Apache Server Name"
sudo apt-get -y install libapache2-mod-security2
sudo sed -i -e "s/ServerTokens OS//g" /etc/apache2/conf-enabled/security.conf
sudo sed -i -e "s/ServerTokens Full//g" /etc/apache2/conf-enabled/security.conf
if ! grep "ServerTokens Full" /etc/apache2/conf-enabled/security.conf >/dev/null
then
sudo bash -c 'echo "ServerTokens Full" >>/etc/apache2/conf-enabled/security.conf'
fi
if ! grep "SecServerSignature Karma/2.0.1" /etc/apache2/conf-enabled/security.conf >/dev/null
then
sudo bash -c 'echo "SecServerSignature Karma/2.0.1" >>/etc/apache2/conf-enabled/security.conf'
fi
fi
fi
if [ -f /tmp/ufw ]; then sudo rm /tmp/ufw ;fi
sudo cp /etc/default/ufw /tmp/ufw
sudo chown $USER /tmp/ufw
if [ $Ipv6 = "NO" ]
then
sudo sed -i '/IPV6=/d' /tmp/ufw
sudo echo "IPV6=no" >> /tmp/ufw
fi
sudo chmod 644 /tmp/ufw
sudo chown root:root /tmp/ufw
sudo cp /tmp/ufw /etc/default/ufw
sudo /etc/init.d/ufw restart
sleep 1
echo -e "\e[33mOpening up Port 22 TCP for SSH:\e[0m"
sudo ufw allow 22/tcp || true
echo -e "\e[33mOpening up Port $drpc_port/$dudp_port for Okcash daemon:\e[0m"
sudo ufw allow $drpc_port,$dudp_port/tcp || true
if [ $Website = "YES" ]
then
echo -e "\e[33mOpening up Port $Website_port for website frontpage:\e[0m"
sudo ufw allow $Website_port/tcp || true

if [ $$Website_daemon = "NGINX" ]
then
sudo ufw allow 'Nginx Full'
fi

fi
echo -e ""
sudo ufw status verbose || true
sudo ufw --force enable || true
echo -e "Done."
}

############
# Main loop#
############
if ! [ -f .pass ]
then
prereq_
mkswap
Download_Extract_
Build_Dependencies_
else
echo -e "\nDependencies were already builded..."
echo -e "Remove file \x22.pass\x22 to restart build..."
sleep 1
fi
if ! [[ -x "$(command -v pv)" || -x "$(command -v ntpd)" || -x "$(command -v lrzip)" || -x "$(command -v pwgen)" || -x "$(command -v htop)" ]]
then
prereq_
fi
sudo ldconfig
Build_Okcash_
conf_

if [ $Website = "YES" ];then install_website_ ;fi
if [ $Raspi_optimize = "YES" ]
then
Raspberry-optimisation_
sudo /etc/init.d/cron stop >/dev/null #add this to prevent accidental restart during bootstrap download process
fi

if [ $Bootstrap = "YES" ] ; then Bootstrap_ ;fi
if [ $AutoStart = "YES" ]; then auto_start_ ;fi
if [ $Firewall = "YES" ] ; then Firewall_ ;fi
if [ $Banner = "YES" ] ; then banner_ ;fi
echo -e "\n\e[97mBuild is finished !!!\e[0m"

if [ $Raspi_optimize = "YES" ];then echo -e "\e[92mRaspberry was optimized : need to reboot ...\e[0m";fi
if [ ! $Website_port = "80" ]
then
_IP=$(hostname -I) || true
echo -e "\e[92mHtml frontend hidden use http://${_IP::-1}:$Website_port to check the webpage \e[0m"
fi

echo -e "\nwareck@gmail.com\n"
echo -e "Donate:"

echo -e "OKcash:  PH3JcR9inEeNZD6gNoLDYwaPAFpgjmrbue"
echo -e "Bitcoin: 1Pu12Wimuy6n7csyHkEjZXGXnAQzKBwSBp"
echo -e "Litecoin: M84U8YggaJ7T5E3TcqgcoF2BCTaxBMbCvN"
echo -e ""

if [ $Dw = 1 ]
then
okcashd
sudo bash -c 'sudo /etc/init.d/cron restart >/dev/null'
fi

if [ $Raspi_optimize = "YES" ]
then
	if [ $Reboot = "YES" ]
	then
	echo -e "Reboot in 10 seconds (CRTL+C to abord):"
	for i in {10..1}
	do
	echo -e -n "$i "
	sleep 1
	done
	echo -e "\n\n"

	sudo reboot
fi
else
	sleep 5
fi
