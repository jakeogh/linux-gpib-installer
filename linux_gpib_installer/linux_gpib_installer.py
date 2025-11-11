#!/usr/bin/env python3
# -*- coding: utf8 -*-
# tab-width:4
# disable: byte-vector-replacer

import os
import sys
from importlib import resources

import click


def root_user():
    if os.getuid() == 0:
        return True
    return False


@click.group(no_args_is_help=True)
def cli() -> None:
    pass


@cli.command()
def debian_11() -> None:
    if root_user():
        print("Dont run this as root.", file=sys.stderr)
        sys.exit(1)

    with resources.path(
        "linux_gpib_installer", "_linux_gpib_installer_debian_11.sh"
    ) as _installer_path:
        _commands = [".", _installer_path.as_posix()]
        _command = " ".join(_commands)
        print(_command)
        os.system(_command)

@cli.command()
def debian_12() -> None:
    if root_user():
        print("Dont run this as root.", file=sys.stderr)
        sys.exit(1)

    with resources.path(
        "linux_gpib_installer", "_linux_gpib_installer_debian_12.sh"
    ) as _installer_path:
        _commands = [".", _installer_path.as_posix()]
        _command = " ".join(_commands)
        print(_command)
        os.system(_command)
