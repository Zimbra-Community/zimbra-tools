# Undo Send

## Usage from CLI

Usage from the command line as zimbra user: 

      /usr/local/sbin/undosend 953242361.435.1586347147822.JavaMail.zimbra@mind.zimbra.io
      
So use value from Message-Id header without <>. Please note, this command line script does not check permissions, so it will remove the mails with the requested message-id if it finds them.
