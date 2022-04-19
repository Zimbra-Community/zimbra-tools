#!/bin/bash

#echo "If your ssh-key is protected with a password it is recommended you run:";
#echo 'ssh-agent bash'
#echo 'ssh-add ~/.ssh/id_rsa'
#echo "Hit enter, if you want to continue running this script, or CTRL+C  to abort";
#read dum;

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa

mkdir ~/Zimbra-Community

cd ~/Zimbra-Community

git clone ssh://git@github.com/Zimbra-Community/ansible-zimbradev
git clone ssh://git@github.com/Zimbra-Community/ADPassword
git clone ssh://git@github.com/Zimbra-Community/printpatch-zimlet
git clone ssh://git@github.com/Zimbra-Community/com_zimbra_stickynotes
git clone ssh://git@github.com/Zimbra-Community/adopted
git clone ssh://git@github.com/Zimbra-Community/ca_uoguelph_ccs_sidebar
git clone ssh://git@github.com/Zimbra-Community/ca_uoguelph_ccs_archive
git clone ssh://git@github.com/Zimbra-Community/group-calendar
git clone ssh://git@github.com/Zimbra-Community/python-zimbra
git clone ssh://git@github.com/Zimbra-Community/zimbra.de_dieploegers_followup
git clone ssh://git@github.com/Zimbra-Community/de_dieploegers_admin_vacation
git clone ssh://git@github.com/Zimbra-Community/de_dieploegers_godate
git clone ssh://git@github.com/Zimbra-Community/pgp-zimlet-test-reports
git clone ssh://git@github.com/Zimbra-Community/pgp-zimlet
git clone ssh://git@github.com/Zimbra-Community/zimbra-tools
git clone ssh://git@github.com/Zimbra-Community/owncloud-zimlet
git clone ssh://git@github.com/Zimbra-Community/list-unsubscribe-zimlet
git clone ssh://git@github.com/Zimbra-Community/zimbra-patches
git clone ssh://git@github.com/Zimbra-Community/attachmentalert-zimlet
git clone ssh://git@github.com/Zimbra-Community/js-zimbra
git clone ssh://git@github.com/Zimbra-Community/zimlets-foss
git clone ssh://git@github.com/Zimbra-Community/build
git clone ssh://git@github.com/Zimbra-Community/zmpublish
git clone ssh://git@github.com/Zimbra-Community/de_dieploegers_savesend
git clone ssh://git@github.com/Zimbra-Community/zopenhsm
git clone ssh://git@github.com/Zimbra-Community/bulkreply-zimlet
git clone ssh://git@github.com/Zimbra-Community/com_zimbra_emailtemplates
git clone ssh://git@github.com/Zimbra-Community/ca_uoguelph_ccs_printbutton
git clone ssh://git@github.com/Zimbra-Community/ZetaAlliance-Graphics
git clone ssh://git@github.com/Zimbra-Community/zmexit
git clone ssh://git@github.com/Zimbra-Community/zimbra-jars
git clone ssh://git@github.com/Zimbra-Community/shared-mailbox-toolkit
git clone ssh://git@github.com/Zimbra-Community/zmsharedgal
git clone ssh://git@github.com/Zimbra-Community/webdav-client-test-reports
git clone ssh://git@github.com/Zimbra-Community/prop2xml
git clone ssh://git@github.com/Zimbra-Community/propmigr
git clone ssh://git@github.com/Zimbra-Community/io_nomennesc_extracontact
git clone ssh://git@github.com/Zimbra-Community/announcements
git clone ssh://git@github.com/Zimbra-Community/com_cloudtemple_senderblocker
git clone ssh://git@github.com/Zimbra-Community/tabiframe-zimlet
git clone ssh://git@github.com/Zimbra-Community/zmantis
git clone ssh://git@github.com/Zimbra-Community/letsencrypt-zimbra
git clone ssh://git@github.com/Zimbra-Community/zimbra-chef
git clone ssh://git@github.com/Zimbra-Community/zmoauthprovext
git clone ssh://git@github.com/Zimbra-Community/com_zimbra_emailreminder
git clone ssh://git@github.com/Zimbra-Community/OCS
git clone ssh://git@github.com/Zimbra-Community/ZimbraScripts
git clone ssh://git@github.com/Zimbra-Community/rmail
git clone ssh://git@github.com/Zimbra-Community/OpenZAL
git clone ssh://git@github.com/Zimbra-Community/account-history
git clone ssh://git@github.com/Zimbra-Community/signature-template
git clone ssh://git@github.com/Zimbra-Community/ZimbraThaiAnalyzer
git clone ssh://git@github.com/Zimbra-Community/mailing-lists
git clone ssh://git@github.com/Zimbra-Community/startmeeting
git clone ssh://git@github.com/Zimbra-Community/zimbra-rocket
git clone ssh://git@github.com/Zimbra-Community/bigbluebutton-zimlet
git clone ssh://git@github.com/Zimbra-Community/user-alias
git clone ssh://git@github.com/Zimbra-Community/zimlet-provisioning
git clone ssh://git@github.com/Zimbra-Community/zimbra-foss-2fa
git clone ssh://git@github.com/Zimbra-Community/reply-by-filter
git clone ssh://git@github.com/Zimbra-Community/unsplash
git clone ssh://git@github.com/Zimbra-Community/proxy
git clone ssh://git@github.com/Zimbra-Community/HPO-Zimlet
git clone ssh://git@github.com/Zimbra-Community/seafile
git clone ssh://git@github.com/Zimbra-Community/zimbra-zimlet-lifesize
git clone ssh://git@github.com/Zimbra-Community/zm-sso
git clone ssh://git@github.com/Zimbra-Community/Alfresco-Zimlet
git clone ssh://git@github.com/Zimbra-Community/zsugar
git clone ssh://git@github.com/Zimbra-Community/zimlet-jitsi-meet
git clone ssh://git@github.com/Zimbra-Community/salesforce
git clone ssh://git@github.com/Zimbra-Community/zimbra-zimlet-bigbluebutton
git clone ssh://git@github.com/Zimbra-Community/zimbra-crowd-extension
git clone ssh://git@github.com/Zimbra-Community/MyZimbra-Cloud
git clone ssh://git@github.com/Zimbra-Community/DAWebmail
git clone ssh://git@github.com/Zimbra-Community/zsuitecrm
git clone ssh://git@github.com/Zimbra-Community/keycloak

cd "$(dirname "$0")"
ls | grep -v pull.sh | xargs -I{} git -C {} pull

echo "All done, please check if there are any errors in the terminal. And hit enter key to exit."
read end;
