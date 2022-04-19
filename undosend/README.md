# Undo Send

A CLI script that can be used to remove email based on the message-id that can act as an Undo Send option. It works on Network Edition only as it basically is a wrapper around `zmmboxsearch`.

**Warning running this script can potentially destroy a lot of messages, so make sure to test it first, have a backup and change the script to fit your needs.**

The script will put a placeholder message, telling the recipient the message with `deleted message subject` was recalled. 

Installation:

      wget https://raw.githubusercontent.com/Zimbra-Community/zimbra-tools/master/undosend/undosend -O /usr/local/sbin/undosend
      chmod +rx /usr/local/sbin/undosend

## Usage from CLI

Usage from the command line as zimbra user: 

      /usr/local/sbin/undosend 953242361.435.1586347147822.JavaMail.zimbra@mind.zimbra.io
      
So use value from Message-Id header without <>. Please note, this command line script does not check permissions, so it will remove the mails with the requested message-id if it finds them.

## Open source edition

Perhaps this script can be made to work with `zmmboxsearchx` from  https://github.com/Zimbra-Community/zimbra-tools/tree/master/zmmboxsearchx but that has yet to be developed and tested.
