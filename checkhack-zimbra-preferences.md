I looked into checkhack-zimbra-preferences, it seems like writing it took a lot of time, and
it is a great effort.

However, I was able to crash the script by adding a plain-text signature for a user (see attached).
The script would then try to create arbitrary files on the server file system. That does suggest
shell escaping is not being done properly by this script.

[root@myzimbra ~]#  /usr/local/sbin/checkhack-zimbra-preferences.sh
/tmp/zimbra-preferences-scores/2016-06-06/admin
/tmp/zimbra-preferences-scores/2016-06-06/if
/tmp/zimbra-preferences-scores/2016-06-06/zimbrapreffromaddress
/tmp/zimbra-preferences-scores/2016-06-06/zimbraprefidentityname
/tmp/zimbra-preferences-scores/2016-06-06/zimbraprefmailforwardingaddress:*|zimbraprefmaillocaldeliverydisabled:*|zimbraprefsavetosent:*|zimbrasignaturename:*|zimbraprefmailsignature:*|zimbraprefmailsignaturehtml:*|zimbraprefidentityname:*|zimbrapreffromdisplay:*|zimbrapreffromaddress:*|zimbraprefreplytodisplay:*|zimbraprefreplytoaddress:*)if
/usr/local/sbin/checkhack-zimbra-preferences.sh[420]: /tmp/zimbra-preferences-scores/2016-06-06/zimbraprefmailforwardingaddress:*|zimbraprefmaillocaldeliverydisabled:*|zimbraprefsavetosent:*|zimbrasignaturename:*|zimbraprefmailsignature:*|zimbraprefmailsignaturehtml:*|zimbraprefidentityname:*|zimbrapreffromdisplay:*|zimbrapreffromaddress:*|zimbraprefreplytodisplay:*|zimbraprefreplytoaddress:*)if: cannot create [File name too long]
/tmp/zimbra-preferences-scores/2016-06-06/zimbrasignaturename


[root@myzimbra ~]# ls --full-time /tmp/zimbra-preferences-scores/2016-06-06/
total 20
 - -rw-------. 1 root root 2 2016-06-06 21:19:12.137399697 +0200 admin
 - -rw-------. 1 root root 2 2016-06-06 21:19:12.145399735 +0200 if
 - -rw-------. 1 root root 2 2016-06-06 21:19:12.152399768 +0200 zimbrapreffromaddress
 - -rw-------. 1 root root 2 2016-06-06 21:19:12.162399815 +0200 zimbraprefidentityname
 - -rw-------. 1 root root 2 2016-06-06 21:19:12.172399863 +0200 zimbrasignaturename


Means, it tried to create a file with name:
/tmp/zimbra-preferences-scores/2016-06-06/zimbraprefmailforwardingaddress:*|zimbraprefmaillocaldeliverydisabled:*|zimbraprefsavetosent:*|zimbrasignaturename:*|zimbraprefmailsignature:*|zimbraprefmailsignaturehtml:*|zimbraprefidentityname:*|zimbrapreffromdisplay:*|zimbrapreffromaddress:*|zimbraprefreplytodisplay:*|zimbraprefreplytoaddress:*)if

This is potentially unsafe, I would require me to rewrite the script to make sure it escapes
all user input. Considering this is a script to prevent hackers and spammer from abusing
services, I do not think I can use it, as is.

See: https://github.com/Zimbra-Community/zimbra-tools/blob/master/checkhack-zimbra-preferences

and injectfile.txt.tar.gz

Kind regards,

Barry de Graaff

