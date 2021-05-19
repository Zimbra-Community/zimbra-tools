#!/bin/bash

cat /opt/zimbra/bin/zmcertmgr | sed '/$self->verifycrt( $type, $keyf, $crtf, $ca_pem )/,+1 d' > /usr/local/sbin/patchedzmcertmgr
