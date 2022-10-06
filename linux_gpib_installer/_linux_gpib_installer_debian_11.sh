#!/bin/bash

# https://gist.github.com/jonathanschilling/07defddc272fe35c7412d51dffa0bb6f
grep "Debian GNU/Linux 11" /etc/issue || { echo "This script requires Debian 11" ; exit 1 ; }
set -x


PATH="/home/user/.local/bin:${PATH}"
export PATH=${PATH}
sudo apt-get install devscripts dkms subversion git -y || exit 1
sudo apt-get install python3-pip -y || exit 1
sudo apt-get install python3-usb -y || exit 1
sudo apt-get install python3-serial -y || exit 1
#sudo apt-get install python3-pyvisa-py -y || exit 1  # pip installs a newer version
#sudo apt-get install python3-wxgtk4.0 -y || exit 1 # for cyclodial_client
sudo pip install git+https://git@github.com/jakeogh/replace-text || exit 1
# https://github.com/drogenlied/linux-gpib-dkms
cd ~/linux-gpib-dkms || { git clone https://github.com/drogenlied/linux-gpib-dkms || exit 1 ; }
cd ~/linux-gpib-dkms && { git pull origin || exit 1 ; }
#svn checkout https://svn.code.sf.net/p/linux-gpib/code/trunk linux-gpib || exit 1  # svn hangs going through university FWs
test -e ~/linux-gpib && rm -rf ~/linux-gpib  # clear the bases
test -e ~/linux-gpib || { cp -ar ~/cycloidal_client/install_scripts/linux-gpib ~/ || exit 1 ; }
cp -ar ~/linux-gpib-dkms/debian ~/linux-gpib/linux-gpib-kernel/ || exit 1
cd ~/linux-gpib/linux-gpib-kernel/ || exit 1
debuild -i -us -uc -b || { echo "ERROR: debbuild failed!" ; exit 1 ; }
ls -al ~/linux-gpib || exit 1
cd ~/linux-gpib || exit 1
sudo  dpkg --install gpib-dkms_*_all.deb || exit 1
cd ~/linux-gpib/linux-gpib-user || exit 1
test -x ./configure || { ./bootstrap || exit 1 ; }
./configure --sysconfdir=/etc || exit 1
sudo apt-get install flex -y || exit 1
sudo apt-get install bison -y || exit 1
sudo apt-get install byacc -y || exit 1
sudo apt-get install x11vnc -y || exit 1
make && sudo make install || exit 1
sudo groupadd gpib # dont exit on $? != 0, groupadd exits 1 if the group already exists
sudo gpasswd -a "$USER" gpib || exit 1
sudo gpasswd -a "$USER" dialout || exit 1
grep "GPIB.CONF IEEE488 library config file" /etc/gpib.conf && sudo mv /etc/gpib.conf /etc/gpib.conf.example
cat << EOF | sudo tee /etc/gpib.conf
interface {
        minor = 0
        board_type = "ni_usb_b"
        pad = 0
        master = yes
}
EOF
sudo ldconfig
#grep -E "^WaylandEnable=false" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#WaylandEnable=false" --replacement "WaylandEnable=false" ; }
#grep -E "^AutomaticLoginEnable=true" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#  AutomaticLoginEnable = true" --replacement "AutomaticLoginEnable=true" ; }
#grep -E "^AutomaticLogin=$USER" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#  AutomaticLogin = user1" --replacement "AutomaticLogin=$USER" ; }
#
#cd ~/cycloidal_client && pip install . || exit 1

echo "Debian 11 linux-gpib install completed OK, A REBOOT IS REQUIRED."
