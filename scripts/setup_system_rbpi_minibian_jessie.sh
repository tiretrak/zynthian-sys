#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Setup Script
# 
# Setup a Zynthian Box in a fresh minibian-jessie installation
# 
# Copyright (C) 2015-2016 Fernando Moyano <jofemodo@zynthian.org>
#
#******************************************************************************
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# For a full copy of the GNU General Public License see the LICENSE.txt file.
# 
#******************************************************************************

export ZYNTHIAN_DIR="/zynthian"
export ZYNTHIAN_SW_DIR="$ZYNTHIAN_DIR/zynthian-sw"
export ZYNTHIAN_UI_DIR="$ZYNTHIAN_DIR/zynthian-ui"
export ZYNTHIAN_SYS_DIR="$ZYNTHIAN_DIR/zynthian-sys"
export ZYNTHIAN_DATA_DIR="$ZYNTHIAN_DIR/zynthian-data"

#------------------------------------------------
# Update System
#------------------------------------------------

apt-get -y update
apt-get -y upgrade
#rpi-update

#------------------------------------------------
# Add Repositories
#------------------------------------------------

# Install required dependencies if needed
apt-get -y install apt-transport-https software-properties-common wget

# deb-multimedia repo
echo "deb http://www.deb-multimedia.org jessie main" >> /etc/apt/sources.list
apt-get -y --force-yes install deb-multimedia-keyring

# Autostatic Repo
wget -O - http://rpi.autostatic.com/autostatic.gpg.key| apt-key add -
wget -O /etc/apt/sources.list.d/autostatic-audio-raspbian.list http://rpi.autostatic.com/autostatic-audio-raspbian.list

apt-get update
#apt-get -y dist-upgrade

#------------------------------------------------
# Install Required Packages
#------------------------------------------------

# System
apt-get -y install apt-utils
apt-get -y remove isc-dhcp-client
apt-get -y install systemd dhcpcd-dbus avahi-daemon
apt-get -y xinit xserver-xorg-video-fbdev x11-xserver-utils
#apt-get -y remove libgl1-mesa-dri

# CLI Tools
apt-get -y install raspi-config psmisc tree joe 
apt-get -y install fbi scrot mpg123
apt-get -y install i2c-tools
apt-get -y install evtest tslib libts-bin # touchscreen tools
#apt-get install python-smbus (i2c with python)

#------------------------------------------------
# Development Environment
#------------------------------------------------

#Tools
apt-get -y install git autoconf premake libtool cmake cmake-curses-gui

# Libraries
apt-get -y install wiringpi libfftw3-dev libmxml-dev zlib1g-dev libfltk1.3-dev libncurses5-dev \
liblo-dev dssi-dev libjpeg-dev libxpm-dev libcairo2-dev libglu1-mesa-dev \
libasound2-dev dbus-x11 jackd2 libjack-jackd2-dev a2jmidid laditools \
liblash-compat-dev libffi-dev fontconfig-config libfontconfig1-dev libxft-dev
#libjack-dev-session
#non-ntk-dev
#libgd2-xpm-dev

# Python
apt-get -y install python-dbus
apt-get -y install python3 python3-dev python3-pip cython3 python3-cffi python3-tk python3-dbus
pip3 install websocket-client
pip3 install JACK-Client

#************************************************
#------------------------------------------------
# Create Zynthian Directory Tree & 
# Install Zynthian Software from repositories
#------------------------------------------------
#************************************************
mkdir $ZYNTHIAN_DIR
cd $ZYNTHIAN_DIR
git clone https://github.com/zynthian/zyncoder.git
mkdir zyncoder/build
cd zyncoder/build
cmake ..
make
cd $ZYNTHIAN_DIR
git clone https://github.com/zynthian/zynthian-ui.git
cd zynthian-ui
git checkout mod
cd $ZYNTHIAN_DIR
git clone https://github.com/zynthian/zynthian-sys.git
git clone https://github.com/zynthian/zynthian-data.git
# TODO => Rethink plugins directory!!
#git clone https://github.com/zynthian/zynthian-plugins.git
git clone https://github.com/zynthian/zynthian-emuface.git
mkdir "zynthian-sw"
mkdir "zynthian-data/soundfonts/sf2"
mkdir "zynthian-data/soundfonts/sfz"
mkdir "zynthian-data/soundfonts/gig"
mkdir "zynthian-my-data"
mkdir "zynthian-my-data/zynbanks"
mkdir "zynthian-my-data/soundfonts"
mkdir "zynthian-my-data/soundfonts/sf2"
mkdir "zynthian-my-data/soundfonts/sfz"
mkdir "zynthian-my-data/soundfonts/gig"
mkdir "zynthian-my-data/snapshots"
mkdir "zynthian-my-plugins"

#************************************************
#------------------------------------------------
# System Adjustments
#------------------------------------------------
#************************************************

#Change Hostname
echo "zynthian" > /etc/hostname

# Copy "boot" config files
cp $ZYNTHIAN_SYS_DIR/boot/* /boot

# Copy "etc" config files
cp $ZYNTHIAN_SYS_DIR/etc/modules /etcdbus-x11
cp $ZYNTHIAN_SYS_DIR/etc/udev/rules.d/* /etc/udev/rules.d
cp $ZYNTHIAN_SYS_DIR/etc/init.d/* /etc/init.d
cp $ZYNTHIAN_SYS_DIR/etc/inittab /etc

# Systemd Services
systemctl enable dhcpcd
systemctl enable avahi-daemon
systemctl disable raspi-config
systemctl disable cron
systemctl disable rsyslog
systemctl disable ntp
systemctl disable triggerhappy
#systemctl disable serial-getty@ttyAMA0.service
#systemctl disable sys-devices-platform-soc-3f201000.uart-tty-ttyAMA0.device
systemctl enable asplashscreen
systemctl enable zynthian

# X11 Config
mkdir /etc/X11/xorg.conf.d
cp $ZYNTHIAN_SYS_DIR/etc/X11/xorg.conf.d/99-calibration.conf /etc/X11/xorg.conf.d
cp $ZYNTHIAN_SYS_DIR/etc/X11/xorg.conf.d/99-pitft.conf /etc/X11/xorg.conf.d

# Setup User Config (root)
# Shell & Login Config
cp $ZYNTHIAN_SYS_DIR/etc/profile.zynthian /root/.profile.zynthian
echo "source .profile.zynthian" >> /root/.profile
# ZynAddSubFX Config
cp $ZYNTHIAN_SYS_DIR/etc/zynaddsubfxXML.cfg /root/.zynaddsubfxXML.cfg

#************************************************
#------------------------------------------------
# Compile / Install Other Required Libraries
#------------------------------------------------
#************************************************

#------------------------------------------------
# Install Alsaseq Python Library
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
wget http://pp.com.mx/python/alsaseq/alsaseq-0.4.1.tar.gz
tar xfvz alsaseq-0.4.1.tar.gz
cd alsaseq-0.4.1
python3 setup.py install
rm -f alsaseq-0.4.1.tar.gz

#------------------------------------------------
# Install NTK
#------------------------------------------------
git clone git://git.tuxfamily.org/gitroot/non/fltk.git ntk
cd ntk
./waf configure
./waf
./waf install

#------------------------------------------------
# Install pyliblo (liblo OSC library for Python)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/dsacre/pyliblo.git
cd pyliblo
python3 ./setup.py build
python3 ./setup.py install

#------------------------------------------------
# Install mod-ttymidi (falkTX's version!)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/moddevices/mod-ttymidi.git
cd mod-ttymidi
make install

#------------------------------------------------
# Install Aubio Library & Tools
#------------------------------------------------
sudo apt-get -y install libsamplerate-dev libsndfile-dev
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/aubio/aubio.git
cd aubio
make -j 4
cp -fa ./build/src/libaubio* /usr/local/lib
cp -fa ./build/examples/aubiomfcc /usr/local/bin
cp -fa ./build/examples/aubionotes /usr/local/bin
cp -fa ./build/examples/aubioonset /usr/local/bin
cp -fa ./build/examples/aubiopitch /usr/local/bin
cp -fa ./build/examples/aubioquiet /usr/local/bin
cp -fa ./build/examples/aubiotrack /usr/local/bin

#************************************************
#------------------------------------------------
# Compile / Install Synthesis Software
#------------------------------------------------
#************************************************

#------------------------------------------------"Incompatible shm registry, are jackd and libjack in sync"
# Install zynaddsubfx
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/fundamental/zynaddsubfx.git
cd zynaddsubfx
mkdir build
cd build
cmake ..
#ccmake .
# => delete "-msse -msse2 -mfpmath=sse" 
# => optimizations: -pipe -mfloat-abi=hard -mfpu=neon-vfpv4 -mvectorize-with-neon-quad -funsafe-loop-optimizations -funsafe-math-optimizations
# => optimizations that doesn't work: -mcpu=cortex-a7 -mtune=cortex-a7
sed -i -- 's/\-march\=armv7\-a \-mfloat\-abi\=hard \-mfpu\=neon \-mcpu\=cortex\-a9 \-mtune\=cortex\-a9 \-pipe \-mvectorize\-with\-neon\-quad \-funsafe\-loop\-optimizations/\-pipe \-mfloat\-abi=hard \-mfpu\=neon\-vfpv4 \-mvectorize\-with\-neon\-quad \-funsafe\-loop\-optimizations \-funsafe\-math\-optimizations/' CMakeCache.txt
make -j 4
make install

#Create soft link to zynbanks
ln -s $ZYNTHIAN_SW_DIR/zynaddsubfx/instruments/banks $ZYNTHIAN_DATA_DIR/zynbanks

#------------------------------------------------
# Install Fluidsynth & SondFonts
#------------------------------------------------
apt-get install fluidsynth fluid-soundfont-gm fluid-soundfont-gs

# Create SF2 soft links
cd $ZYNTHIAN_DATA_DIR/soundfonts/sf2
ln -s /usr/share/sounds/sf2/*.sf2 .

#------------------------------------------------
# Install Linuxsampler => TODO Upgrade to Version 2
#------------------------------------------------
apt-get -y install linuxsampler

#------------------------------------------------
# Install Fantasia (linuxsampler Java GUI)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
mkdir fantasia
cd fantasia
wget http://downloads.sourceforge.net/project/jsampler/Fantasia/Fantasia%200.9/Fantasia-0.9.jar
# java -jar ./Fantasia-0.9.jar

#------------------------------------------------
# Install setBfree
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/pantherb/setBfree.git
cd setBfree
sed -i -- 's/\-msse \-msse2 \-mfpmath\=sse/\-pipe \-mcpu\=cortex\-a7 \-mfpu\=neon\-vfpv4 \-mfloat\-abi\=hard \-mvectorize\-with\-neon\-quad \-funsafe\-loop\-optimizations \-funsafe\-math\-optimizations/g' common.mak
make -j 4 ENABLE_ALSA=yes
make install

#------------------------------------------------
# Install some extra LV2 Plugins (Calf, MDA, ...)
#------------------------------------------------
apt-get install calf-plugins mda-lv2 swh-lv2 lv2vocoder avw.lv2
apt-get install synthv1 samplv1 drumkv1

#------------------------------------------------
# Install DISTRHO DPF-Plugins
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/DISTRHO/DPF-Plugins.git
cd DPF-Plugins
export RASPPI=true
make -j 4
make install

#------------------------------------------------
# Install DISTRHO Plugins-Ports
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR/zynthian-sw
git clone https://github.com/DISTRHO/DISTRHO-Ports.git
cd DISTRHO-Ports
./scripts/premake-update.sh linux
#edit ./scripts/premake.lua
make -j 4
make install


#------------------------------------------------
# Install MOD stuff
#------------------------------------------------

#Holger scripts ...
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/dcoredump/zynthian-recipe.git

