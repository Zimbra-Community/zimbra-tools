# Checkdevices

A python script comparing the synchronized devices in Zimbra with a list of 
approved devices to filter out unauthorized use.

## Prerequisites

* [Cement](http://builtoncement.com/) >2.4
* [Python-Zimbra](https://github.com/Zimbra-Community/python-zimbra) >2.0

This script only supports the Zimbra Network Edition currently.

## Usage

Run the script with the Zimbra server hostname, an admin user and a text file
 containing the password for that user or (not recommended) the password itself.
 
Additionally, specify a file, which contains rules for approved devices.

These rules are basically just a device-key and a regexp for an approved 
device like <device-key>=<regexp>

For more parameters and information, use:

    python checkdevices.sh --help
 
## Approvement examples

To approve all iPads, use the following line:

type=iPad

To approve all iPads and iPhones, use the following line:

type=iP.*

To approve a specific device id, use:

id=fnuiwn4bi32bui324

For all available device keys, just run the device with an empty approved 
file and see, what devices are in your environment.
