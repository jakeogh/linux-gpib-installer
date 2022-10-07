#!/bin/bash

# https://gist.github.com/jonathanschilling/07defddc272fe35c7412d51dffa0bb6f
grep "Debian GNU/Linux 11" /etc/issue || { echo "This script requires Debian 11" ; exit 1 ; }
set -x

module_path=$(python3 << EOF
from importlib import resources
with resources.path('linux_gpib_installer', '_linux_gpib_installer_debian_11.sh') as rp:
        print(rp.parent.as_posix())
EOF
)

echo "${module_path}"

linux_gpib_repo="${module_path}/linux-gpib"
test -d "${linux_gpib_repo}" || { echo "${linux_gpib_repo} is not a directory. Exiting." ; exit 1 ; }

PATH="/home/${USER}/.local/bin:${PATH}"
export PATH=${PATH}


work="/home/${USER}/tmp"
mkdir "/home/${USER}/tmp" > /dev/null 2>&1
test -d "${linux_gpib_repo}" || { echo "${work} is not a directory. Exiting." ; exit 1 ; }

echo "work: ${work}"
cd "${work}" || exit 1

sudo apt-get install devscripts dkms subversion git -y || exit 1
sudo apt-get install python3-pip -y || exit 1
sudo apt-get install python3-usb -y || exit 1
sudo apt-get install python3-serial -y || exit 1
#sudo apt-get install python3-pyvisa-py -y || exit 1  # pip installs a newer version
#sudo apt-get install python3-wxgtk4.0 -y || exit 1 # for cyclodial_client

# cwd == ${work}

# https://github.com/drogenlied/linux-gpib-dkms
cd linux-gpib-dkms || { git clone https://github.com/drogenlied/linux-gpib-dkms || exit 1 ; }
cd linux-gpib-dkms && { git pull origin --ff-only || exit 1 ; }

cd "${work}" || exit 1

#svn checkout https://svn.code.sf.net/p/linux-gpib/code/trunk linux-gpib || exit 1  # svn hangs going through university FWs
test -e linux-gpib && rm -rf linux-gpib  # clear the bases
test -e linux-gpib || { cp -ar "${linux_gpib_repo}" . || exit 1 ; }
cp -ar "${work}"/linux-gpib-dkms/debian "${work}"/linux-gpib/linux-gpib-kernel/ || exit 1
cd linux-gpib/linux-gpib-kernel || exit 1
debuild -i -us -uc -b || { echo "ERROR: debbuild failed!" ; exit 1 ; }
ls -al "${work}"/linux-gpib || exit 1
cd "${work}"/linux-gpib || exit 1
sudo  dpkg --install gpib-dkms_*_all.deb || exit 1
cd "${work}"/linux-gpib/linux-gpib-user || exit 1
test -x ./configure || { ./bootstrap || exit 1 ; }
./configure --sysconfdir=/etc || exit 1
sudo apt-get install flex -y || exit 1  # needed for make
sudo apt-get install bison -y || exit 1
sudo apt-get install byacc -y || exit 1
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
#sudo pip install git+https://git@github.com/jakeogh/replace-text || exit 1
#sudo apt-get install x11vnc -y || exit 1
#grep -E "^WaylandEnable=false" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#WaylandEnable=false" --replacement "WaylandEnable=false" ; }
#grep -E "^AutomaticLoginEnable=true" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#  AutomaticLoginEnable = true" --replacement "AutomaticLoginEnable=true" ; }
#grep -E "^AutomaticLogin=$USER" /etc/gdm3/daemon.conf || { mpp /etc/gdm3/daemon.conf | sudo replace-text --match "#  AutomaticLogin = user1" --replacement "AutomaticLogin=$USER" ; }
#
#cd ~/cycloidal_client && pip install . || exit 1

echo "Debian 11 linux-gpib install completed OK, A REBOOT IS REQUIRED."
