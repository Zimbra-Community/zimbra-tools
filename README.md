# Zimbra Community Tools

This is an assortment of tools for various administrative tasks for the Zimbra
 Collaboration Suite.
  
These tools are currently available:

* checkdevices (contributed by Dennis Ploeger) - A python script for reporting 
unauthorized device use in Zimbra

## External tools

The following tools are available from their own repositories or websites:

* [Zimbra ZCO Report script (by silpion)](https://github.com/silpion/zmzcoreport) - Report the versions of the Zimbra Connector for Outlook currently in use
* [Zmbkpose](https://github.com/bggo/Zmbkpose) - A GPL licensed shell script that does hot backup and hot restore of ZCS Opensource accounts.
* [Ansible Role](https://github.com/pbruna/ansible-zimbradev) - Ansible Role to make Zimbra Deployment easier when you are testing or coding
* [Zlockout Monitor](https://github.com/howanitz/zimbra_lockoutd) - A log monitoring daemon that sends an email alert to the admin when a user account goes into lockout mode because of too many failed attempts (e.g. from a dictionary attack)

## Zimbra FOSS HSM 

Hierarchical storage allows for older content (mails) to be moved to slower/cheaper storage. Allowing users to have large mailboxes.
[https://github.com/cainelli/zopenhsm](https://github.com/cainelli/zopenhsm)

For archival purpose we also forked this repo to:
[https://github.com/Zimbra-Community/zopenhsm](https://github.com/Zimbra-Community/zopenhsm)

## Automated cbpolicd installer

Automated cbpolicd installer for single-server Zimbra 8.6 on CentOS 6 and 7

[https://github.com/Zimbra-Community/zimbra-tools/blob/master/cbpolicyd.sh](https://github.com/Zimbra-Community/zimbra-tools/blob/master/cbpolicyd.sh)

## COS report

This script is designed to print out a chart showing all zimbra COS and which servers are associated with each

[https://github.com/Zimbra-Community/zimbra-tools/blob/master/zimbraCOS-Builder.pl](https://github.com/Zimbra-Community/zimbra-tools/blob/master/zimbraCOS-Builder.pl)

## pull.sh

Download all repositories in Zimbra-Community, bash -x pull.sh
