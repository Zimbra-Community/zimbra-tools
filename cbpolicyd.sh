#!/bin/bash

# Copyright (C) 2016-2023  Barry de Graaff
# 
# Bugs and feedback: https://github.com/Zimbra-Community/zimbra-tools/issues
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

set -e
# if you want to trace your script uncomment the following line
# set -x
# Documentation used from https://www.zimbrafr.org/forum/topic/7623-poc-zimbra-policyd/
# https://wiki.zimbra.com/wiki/Postfix_Policyd#Example_Configuration
# Thanks 

echo "Automated cbpolicd installer for single-server. Tested on Zimbra 8.8.15 p7 CentOS7, Zimbra 9.0.0 p29 CentOS 7, Zimbra 9.0.0 patch 29 on Ubuntu 20, Zimbra 10 on Ubuntu 20.
- Installs policyd on MariaDB or MySQL (shipped with Zimbra) and show commands on how to activate on Zimbra
- No webui is installed"

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

CBPOLICYD_PWD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-10};echo;)

# creating a user, just to make sure we have one (for mysql on CentOS 6, so we can execute the next mysql queries w/o errors)
POLICYDDBCREATE="$(mktemp /tmp/policyd-dbcreate.XXXXXXXX.sql)"
cat <<EOF > "${POLICYDDBCREATE}"
CREATE DATABASE policyd_db CHARACTER SET 'UTF8'; 
CREATE USER 'ad-policyd_db'@'localhost' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'localhost' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

/opt/zimbra/bin/mysql --force < "${POLICYDDBCREATE}" > /dev/null 2>&1

cat <<EOF > "${POLICYDDBCREATE}"
DROP USER 'ad-policyd_db'@'localhost';
DROP DATABASE policyd_db;
CREATE DATABASE policyd_db CHARACTER SET 'UTF8'; 
CREATE USER 'ad-policyd_db'@'localhost' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'localhost' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

echo "Creating database and user"
/opt/zimbra/bin/mysql < "${POLICYDDBCREATE}"

if [ -d "/opt/zimbra/common/share/database/" ]; then
   #shipped version from Zimbra (8.7)
   cd /opt/zimbra/common/share/database/ >/dev/null
else
   #shipped version from Zimbra (8.6)
   cd /opt/zimbra/cbpolicy*/share/database/ >/dev/null
fi

POLICYDTABLESSQL="$(mktemp /tmp/policyd-dbtables.XXXXXXXX.sql)"
for i in core.tsql access_control.tsql quotas.tsql amavis.tsql checkhelo.tsql checkspf.tsql greylisting.tsql accounting.tsql; 
	do 
	./convert-tsql mysql $i;
	done > "${POLICYDTABLESSQL}"

# have to replace TYPE=InnoDB with ENGINE=InnoDB, this is not needed when using the latest upstream version of cbpolicyd
# but it seems to be an issue in the version shipped with Zimbra 8.6 (not 8.7)
if grep --quiet -e "TYPE=InnoDB" "${POLICYDTABLESSQL}"; then
   grep -lZr -e "TYPE=InnoDB" "${POLICYDTABLESSQL}" | xargs -0 sed -i "s^TYPE=InnoDB^ENGINE=InnoDB^g"
fi

echo "Populating policyd_db please wait..."
/opt/zimbra/bin/mysql policyd_db < "${POLICYDTABLESSQL}"


CBPOLICYDCONF="$(mktemp /tmp/cbpolicyd.conf.in.XXXXXXXX)"
echo "Backing up cbpolicyd.conf.in"
cp -a /opt/zimbra/conf/cbpolicyd.conf.in ${CBPOLICYDCONF}

echo "Setting username in /opt/zimbra/conf/cbpolicyd.conf.in"
grep -lZr -e ".*sername=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in" | xargs -0 sed -i "s^.*sername=.*$^Username=ad-policyd_db^g"

echo "Setting password in /opt/zimbra/conf/cbpolicyd.conf.in"
grep -lZr -e ".*assword=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in"  | xargs -0 sed -i "s^.*assword=.*$^Password=${CBPOLICYD_PWD}^g"

echo "Setting database in /opt/zimbra/conf/cbpolicyd.conf.in"
grep -lZr -e "DSN=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in"  | xargs -0 sed -i "s^DSN=.*$^DSN=DBI:mysql:database=policyd_db;host=127.0.0.1;port=7306^g"

POLICYDPOLICYSQL="$(mktemp /tmp/policyd-policy.XXXXXXXX.sql)"
cat <<EOF > "${POLICYDPOLICYSQL}"
INSERT INTO policies (ID, Name,Priority,Description) VALUES(6, 'Zimbra CBPolicyd Policies', 0, 'Zimbra CBPolicyd Policies');
INSERT INTO policy_members (PolicyID,Source,Destination) VALUES(6, 'any', 'any');
INSERT INTO quotas (PolicyID,Name,Track,Period,Verdict,Data) VALUES (6, 'Sender:user@domain','Sender:user@domain', 60, 'DEFER', 'You are sending too many emails, contact helpdesk');
INSERT INTO quotas (PolicyID,Name,Track,Period,Verdict) VALUES (6, 'Recipient:user@domain', 'Recipient:user@domain', 60, 'REJECT');
INSERT INTO quotas_limits (QuotasID,Type,CounterLimit) VALUES(3, 'MessageCount', 100);
INSERT INTO quotas_limits (QuotasID,Type,CounterLimit) VALUES(4, 'MessageCount', 125);
EOF

echo "Setting basic quota policy"

/opt/zimbra/bin/mysql policyd_db < "${POLICYDPOLICYSQL}"

echo "Installing reporting commands"
echo "/opt/zimbra/bin/mysql policyd_db -e \"select count(instance) count, sender from session_tracking where date(from_unixtime(unixtimestamp))=curdate() group by sender order by count desc;\"" > /usr/local/sbin/cbpolicyd-report
chmod +rx /usr/local/sbin/cbpolicyd-report

echo "Setting up cron"

if [[ -x "/opt/zimbra/common/bin/cbpadmin" ]]
then
   #8.7
    echo "35 3 * * * zimbra bash -l -c '/opt/zimbra/common/bin/cbpadmin --config=/opt/zimbra/conf/cbpolicyd.conf --cleanup' >/dev/null" > /etc/cron.d/cbpolicyd-cleanup
elif  [[ -x "/opt/zimbra/cbpolicyd/bin/cbpadmin" ]]
then
    #8.6
    echo "35 3 * * * zimbra bash -l -c '/opt/zimbra/cbpolicyd/bin/cbpadmin --config=/opt/zimbra/conf/cbpolicyd.conf --cleanup' >/dev/null" > /etc/cron.d/cbpolicyd-cleanup
else
    echo "cbpadmin is not found in /opt/zimbra"
fi

echo "--------------------------------------------------------------------------------------------------------------
CBPolicyd installed successful, the following policy is installed:
- Rate limit any sender from sending more then 100 emails every 60 seconds. Messages beyond this limit are deferred.
- Rate limit any @domain from receiving more then 125 emails in a 60 second period. Messages beyond this rate are rejected.

For your reference:
- Database policyd_db and user have been created using: 
  ${POLICYDDBCREATE}
- Database structure has been created using:
  ${POLICYDTABLESSQL}
- The quota/rate limiting policy has been created using:
  ${POLICYDPOLICYSQL}
- A configuration backup is in:
  ${CBPOLICYDCONF}   
- Running config is in:
  /opt/zimbra/conf/cbpolicyd.conf.in
- Database clean-up is scheduled daily at 03:35AM using:
  /etc/cron.d/cbpolicyd-cleanup

Here are some tips:
- You can run /usr/local/sbin/cbpolicyd-report 
  to show message count by sender/day 
- On Zimbra patches and upgrades, you may need to re-run
  this script or re-apply the configuration  
- You can change or review your polcies using mysql client:
  /opt/zimbra/bin/mysql policyd_db
  SELECT * FROM quotas_limits;
  UPDATE quotas_limits SET CounterLimit = 30 WHERE ID = 4;

To activate your configuration, run as zimbra user:
zmprov ms \$(zmhostname) +zimbraServiceEnabled cbpolicyd
zmprov ms \$(zmhostname) zimbraCBPolicydQuotasEnabled TRUE

Rebooting your server will tell the MTA to start using cbpolicyd and works for sure.
You can also try using zmmtactl restart and zmcbpolicydctl start (in that order!). 
Testing shows that using zmcontrol restart does not enable cbpolicyd.

You can find logging here:
tail -f /opt/zimbra/log/cbpolicyd.log
--------------------------------------------------------------------------------------------------------------
"
