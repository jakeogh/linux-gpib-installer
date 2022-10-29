# -*- coding: utf-8 -*-

import sys

from setuptools import find_packages
from setuptools import setup

if not sys.version_info[0] == 3:
    sys.exit("Python 3 is required. Use: 'python3 setup.py install'")

dependencies = [
    "click",
    "pyvisa",
    "PyVISA-py",
]

config = {
    "version": "0.1",
    "name": "linux_gpib_installer",
    "url": "https://github.com/jakeogh/linux-gpib-installer",
    "license": "Unlicense",
    "author": "Justin Keogh",
    "author_email": "github.com@v6y.net",
    "description": "installer for GPIB drivers",
    "long_description": __doc__,
    "packages": find_packages(exclude=["tests"]),
    "include_package_data": True,
    "zip_safe": False,
    "platforms": "any",
    "install_requires": dependencies,
    "entry_points": {
        "console_scripts": [
            "linux-gpib-installer=linux_gpib_installer.linux_gpib_installer:cli",
        ],
    },
}

setup(**config)
