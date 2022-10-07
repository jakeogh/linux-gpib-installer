**linux-gpib-installer**:  https://github.com/jakeogh/linux-gpib-installer

### Description:
**linux-gpib-installer** automates the installation of [linux-gpib](https://linux-gpib.sourceforge.io/) using the [DKMS](https://github.com/dell/dkms) build from [linux-gpib-dkms](https://github.com/drogenlied/linux-gpib-dkms), it is a updated implementation of the instructions found at: https://gist.github.com/jonathanschilling/07defddc272fe35c7412d51dffa0bb6f

Currently only [Debian 11](https://www.linuxtechi.com/how-to-install-debian-11-bullseye/) is supported.

Automatic configuration is done for the National Instruments [GPIB-USB-HS](https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z000000P8kcSAC) USB dongle, if you are using a PCI card, please see `/etc/gpib.conf.example` and make the approprate changes to `/etc/gpib.conf`


### Installation:
```
$ sudo apt-get install python3-pip -y
$ pip install git+https://git@github.com/jakeogh/linux-gpib-installer
$ source ~/.profile
```

### Usage:

Once linux-gpib-installer is available on your local Debian 11 system, you can then execute:

```
$ linux-gpib-installer debian-11
```

This will install the linux-gpib kernel drivers and userspace components. If the install completed sucessfully, the last line should read:
```
"Debian 11 linux-gpib install completed OK, A REBOOT IS REQUIRED."
```

#### After rebooting:

1. Plug in the GPIB-USB-HS (National Instruments USB->GPIB dongle)
2. Connect GPIB-USB-HS to a GPIB device (note GPIB connectors are often difficult to seat)
3. Power on the GPIB device


### Testing:

1. Execute a test program:

```
$ ipython
Python 3.9.2 (default, Feb 28 2021, 17:03:44)
Type 'copyright', 'credits' or 'license' for more information
IPython 8.5.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: import pyvisa

In [2]: rm = pyvisa.ResourceManager()

In [3]: rm.list_resources()
libgpib: invalid descriptor  # note this message is repeated, this is normal and needs to be fixed in the linux-gpib package
Out[3]: ('ASRL/dev/ttyS0::INSTR', 'GPIB0::2::INSTR')

In [4]: inst = rm.open_resource('GPIB0::2::INSTR')

In [5]: print(inst.query("*IDN?"))
TEKTRONIX,AFG3022B,C037086,SCPI:99.0 FV:3.2.2

```

### Troubleshooting:

1. Make sure GPIB-USB-HS is listed in the output of `lsusb`:
```
$ lsusb | grep GPIB-USB-HS
Bus 001 Device 003: ID 3923:709b National Instruments Corp. GPIB-USB-HS
```

2. Watch the kernel log while plugging GPIB-USB-HS into the computer, the output should be:
```
$ sudo dmesg -w
[114002.392720] usb 1-3: USB disconnect, device number 3
[114005.075248] usb 1-3: new high-speed USB device number 4 using xhci_hcd
[114005.300772] usb 1-3: New USB device found, idVendor=3923, idProduct=709b, bcdDevice= 1.01
[114005.300774] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[114005.300776] usb 1-3: Product: GPIB-USB-HS
[114005.300777] usb 1-3: Manufacturer: National Instruments
[114005.300778] usb 1-3: SerialNumber: 015E2ABE
[114005.302890] ni_usb_gpib: probe succeeded for path: usb-0000:02:00.0-3
[114005.579304] usb 1-2: new full-speed USB device number 5 using xhci_hcd
[114005.736502] usb 1-2: New USB device found, idVendor=067b, idProduct=2303, bcdDevice= 3.00
[114005.736504] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[114005.736506] usb 1-2: Product: USB-Serial Controller
[114005.736507] usb 1-2: Manufacturer: Prolific Technology Inc.
[114005.753835] gpib0: exiting autospoll thread
[114005.753917] ni_usb_gpib: attach
[114005.753924] usb 1-3: bus 1 dev num 4 attached to gpib minor 0, NI usb interface 0
[114005.755170]         product id=0x709b
[114005.758501] ni_usb_hs_wait_for_ready: board serial number is 0x15e2abe
[114005.766442] usbcore: registered new interface driver usbserial_generic
[114005.766873] usbserial: USB Serial support registered for generic
[114005.771186] usbcore: registered new interface driver pl2303
[114005.771815] usbserial: USB Serial support registered for pl2303
[114005.771942] pl2303 1-2:1.0: pl2303 converter detected
[114005.780654] usb 1-2: pl2303 converter now attached to ttyUSB0
[114005.864431] /var/lib/dkms/gpib/4.3.5+svn2039/build/drivers/gpib/ni_usb/ni_usb_gpib.c: ni_usb_hs_wait_for_ready: unexpected data: buffer[7]=0x4, expected 0x3 or 0x5 or 0x6
[114005.864437] /var/lib/dkms/gpib/4.3.5+svn2039/build/drivers/gpib/ni_usb/ni_usb_gpib.c: ni_usb_hs_wait_for_ready: unexpected data: buffer[10]=0x3, expected 0x96 or 0x07
[114005.864438] ni_usb_dump_raw_block:

[114005.864441]  40
[114005.864442]   1
[114005.864443]   0
[114005.864444]   8
[114005.864445]  30
[114005.864446]   0
[114005.864447]   2
[114005.864448]   4

[114005.864450]   0
[114005.864451]   0
[114005.864452]   3

```

3. Verify the output of `pyvisa-info` is similar to:
```
$ pyvisa-info
Machine Details:
   Platform ID:    Linux-5.10.0-18-amd64-x86_64-with-glibc2.31
   Processor:

Python:
   Implementation: CPython
   Executable:     /usr/bin/python3
   Version:        3.9.2
   Compiler:       GCC 10.2.1 20210110
   Bits:           64bit
   Build:          Feb 28 2021 17:03:44 (#default)
   Unicode:        UCS4

PyVISA Version: 1.12.0

Backends:
   ivi:
      Version: 1.12.0 (bundled with PyVISA)
      Binary library: Not found
   py:
      Version: 0.5.3
      ASRL INSTR: Available via PySerial (3.5b0)
      USB INSTR: Available via PyUSB (1.0.2). Backend: libusb1
      USB RAW: Available via PyUSB (1.0.2). Backend: libusb1
      TCPIP INSTR: Available
      TCPIP SOCKET: Available
      GPIB INSTR: Available via Linux GPIB (b'4.3.5 r[2041]')
      GPIB INTFC: Available via Linux GPIB (b'4.3.5 r[2041]')

```

4. Observe the 2 LED's that are on the GPIB-USB-HS dongle:

    a. The "READY" LED should be illuminated whenever the dongle is plugged into the computer.

    b. the "ACTIVE" LED should illuminate whenever data is sent. Use the following "oneliner" to test it: `$ python3 -c "import pyvisa; rm=pyvisa.ResourceManager(); rm.list_resources()" > /dev/null 2>&1`

    c. If the green "ACTIVE" LED illuminates, then the computer->GPIB-USB-HS is working correctly, and the problem is further down the line.


### Examples:
```
$ linux-gpib-installer

$ linux-gpib-installer --help
Usage: linux-gpib-installer [OPTIONS] COMMAND [ARGS]...

Options:
  -v, --verbose
  --dict
  --verbose-inf
  --help         Show this message and exit.

Commands:
  debian-11

```
