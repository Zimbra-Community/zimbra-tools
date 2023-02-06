# Zimbra Community Tools

This is an assortment of tools for various administrative tasks for the Zimbra
 Collaboration Suite.
  
These tools are currently available:

## Kickstart file for automatic creation of Zimbra 8.7 repo mirror
This kickstart file automates this wiki: https://wiki.zimbra.com/wiki/Zimbra_Collaboration_repository

You can create your repo using KVM by doing something similar to: https://github.com/Zimbra-Community/pgp-zimlet/blob/stable/kvm/virt-install.sh or you can start the kickstart with a CentOS7 install ISO. After installation you only need to copy your SSL key and crt file to the new server.

https://github.com/Zimbra-Community/zimbra-tools/blob/master/centos7-zimbra-repo.cfg


## Zimbra Docker by ZeXtras
[https://hub.docker.com/r/zextras/zimbra8/](https://hub.docker.com/r/zextras/zimbra8/)

## checkdevices (contributed by Dennis Ploeger)
A python script for reporting unauthorized device use in Zimbra

## External tools

The following tools are available from their own repositories or websites:

* [Zimbra ZCO Report script (by silpion)](https://github.com/silpion/zmzcoreport) - Report the versions of the Zimbra Connector for Outlook currently in use
* [Zmbkpose](https://github.com/bggo/Zmbkpose) - A GPL licensed shell script that does hot backup and hot restore of ZCS Opensource accounts.
* [Ansible Role](https://github.com/pbruna/ansible-zimbradev) - Ansible Role to make Zimbra Deployment easier when you are testing or coding
* [Zlockout Monitor](https://github.com/kenji21/zimbra_lockoutd) - A log monitoring daemon that sends an email alert to the admin when a user account goes into lockout mode because of too many failed attempts (e.g. from a dictionary attack)

## Zimbra FOSS HSM 

Hierarchical storage allows for older content (mails) to be moved to slower/cheaper storage. Allowing users to have large mailboxes.
[https://github.com/cainelli/zopenhsm](https://github.com/cainelli/zopenhsm)

For archival purpose we also forked this repo to:
[https://github.com/Zimbra-Community/zopenhsm](https://github.com/Zimbra-Community/zopenhsm)

## Automated cbpolicd installer

Automated cbpolicd installer for single-server Zimbra 8.8.15 patch 7 on CentOS 7

[https://github.com/Zimbra-Community/zimbra-tools/blob/master/cbpolicyd.sh](https://github.com/Zimbra-Community/zimbra-tools/blob/master/cbpolicyd.sh)

## COS report

This script is designed to print out a chart showing all zimbra COS and which servers are associated with each

[https://github.com/Zimbra-Community/zimbra-tools/blob/master/zimbraCOS-Builder.pl](https://github.com/Zimbra-Community/zimbra-tools/blob/master/zimbraCOS-Builder.pl)

## pull.sh

Download all repositories in Zimbra-Community, bash -x pull.sh

## zmmboxsearchx for Zimbra foss
The CLI command zmmboxsearchx is used to search across mailboxes. You can search across mailboxes to find messages and attachments that match specific criteria and save copies of these messages to a directory. Created by Phil Pearl as part of bug 43265.

This tool is a bit buggy, if it fails, trying again usually does the trick. 

    zmmboxsearchx --query admin --account admin@myzimbra.com,test@myzimbra.com

    wget https://github.com/Zimbra-Community/zimbra-tools/raw/master/alien-8.95/zmmboxsearchx-20100625-2.noarch.rpm
    rpm -i zmmboxsearchx-20100625-2.noarch.rpm
    -or-
    wget https://github.com/Zimbra-Community/zimbra-tools/raw/master/alien-8.95/zmmboxsearchx.deb
    dpkg -i zmmboxsearchx.deb

Example: `zmmboxsearchx --query admin --account testuser3@myzimbra.com,admin@myzimbra.com,test@myzimbra.com`

## Authentication token decoding tools

You can decode the Zimbra authentication token cookie using `zmprov gati <ZM_AUTH_TOKEN>` from the command line on a Zimbra server. You can also use the stand-alone Perl script from [https://github.com/Zimbra-Community/zimbra-tools/blob/master/zmdecodeauthtoken.pl](https://github.com/Zimbra-Community/zimbra-tools/blob/master/zmdecodeauthtoken.pl)
