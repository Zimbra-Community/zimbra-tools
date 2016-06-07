​​​​​-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

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
Zeta Alliance Founder
www.zetalliance.org

Skype: barrydegraaff.tk
Fingerprint: 9e0e165f06b365ee1e47683e20f37303c20703f8
-----BEGIN PGP SIGNATURE-----
Version: OpenPGP.js v2.3.0
Comment: http://openpgpjs.org

wsFcBAEBCAAQBQJXVlUxCRAg83MDwgcD+AAA504QAKArsOM2aVoyBFHwZlZb
HuqTuaDO7PY4dM89f4G5mn3fN6ILC2O9Pmhu81/COD5oZJpgAoOSGsJoGH0l
GXS0yHxrx2TtWT2Oe2PWWLMpErL+JQO1o2vQNru7NV8SJpFi1ZQhFC3kwIHE
YizpJTCCKJIZdlGJUnOlwjiYT/3ugKV2G2jNfSWxKRgaA0Zevnk1q3DSJN6l
nl3usSjDyVftyaiakfc0iyd2XaCJBRonkLYOnOkQE0ql/7mFrUUDE/iYS3Mr
popYGTssY2S/WQkbYzCHFPsqkQWzl9M3zBPVFF0FRB1TkOGMalh7oDrG+eKv
hpdTBz0srhdRbwf7taTEyvu3JenNaA+ZDHFWAB3NgSFifQsonwdpEXCWjf5J
wJjF/EgcCyxMc5uSrxFCjhhpcouIZgqv0k8XcKzcmLDPEZO3nMKQnt1SFKLF
7quKw1Z0ESNuXMgBWdF0qgcjkasRg7Dq/I/Nf34xX6dqOifjwAkCOr8RWulh
NnLgBBW8N/hVjTOT1idmWtJoXuqk1NnSAFU0PCxiSHi1D64fqeZn9H9ErdSi
Ukcrg9+XHP9saiIyPxyX0JbNvfP3ScU9FMGe43+IdABUG5m90fLg5Wn1gPZy
gpvKR8XXFP0QqRUnC13TM0IowObweFURf1ZGsoxznZfXsQt7mTTd+tp41MR+
K4Qm
=Vg1d
-----END PGP SIGNATURE-----
