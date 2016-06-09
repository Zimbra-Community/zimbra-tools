#!/bin/bash

# Copyright (C) 2016  Barry de Graaff
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

echo "Automated cbpolicd installer for single-server Zimbra 8.6 on CentOS 6 or 7 (Ubuntu untested)
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
CREATE USER 'ad-policyd_db'@'127.0.0.1' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'127.0.0.1' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

/opt/zimbra/bin/mysql --force < "${POLICYDDBCREATE}" > /dev/null 2>&1

cat <<EOF > "${POLICYDDBCREATE}"
DROP USER 'ad-policyd_db'@'127.0.0.1';
DROP DATABASE policyd_db;
CREATE DATABASE policyd_db CHARACTER SET 'UTF8'; 
CREATE USER 'ad-policyd_db'@'127.0.0.1' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'127.0.0.1' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

/opt/zimbra/bin/mysql < "${POLICYDDBCREATE}"

echo "For your reference the database policyd_db and user have been created using: ${POLICYDDBCREATE}"

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
	done > ""${POLICYDTABLESSQL}""

# have to replace TYPE=InnoDB with ENGINE=InnoDB, this is not needed when using the latest upstream version of cbpolicyd
# but it seems to be an issue in the version shipped with Zimbra 8.6 (not 8.7)
if grep --quiet -e "TYPE=InnoDB" "${POLICYDTABLESSQL}"; then
   grep -lZr -e "TYPE=InnoDB" "${POLICYDTABLESSQL}" | xargs -0 sed -i "s^TYPE=InnoDB^ENGINE=InnoDB^g"
fi

echo "Please wait... policyd_db populating..."
/opt/zimbra/bin/mysql policyd_db < "${POLICYDTABLESSQL}"
echo "For your reference the database policyd_db populated using: ${POLICYDTABLESSQL}"

CBPOLICYDCONF="$(mktemp /tmp/cbpolicyd.conf.in.XXXXXXXX)"
echo "Backing up /opt/zimbra/conf/cbpolicyd.conf.in in ${CBPOLICYDCONF}"
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
INSERT INTO quotas (PolicyID,Name,Track,Period,Verdict,Data) VALUES (6, 'Sender:user@domain','Sender:user@domain', 60, 'DEFER', 'Deferring: Too many messages from sender in last 60');
INSERT INTO quotas (PolicyID,Name,Track,Period,Verdict) VALUES (6, 'Recipient:@domain', 'Recipient:@domain', 60, 'REJECT');
INSERT INTO quotas_limits (QuotasID,Type,CounterLimit) VALUES(3, 'MessageCount', 20);
INSERT INTO quotas_limits (QuotasID,Type,CounterLimit) VALUES(4, 'MessageCount', 50);
EOF

echo "Setting basic policy
- Rate limit any sender from sending more then 20 emails every 60 seconds. Messages beyond this limit are deferred.
- Rate limit any @domain from receiving more then 50 emails in a 60 second period. Messages beyond this rate are rejected.
${POLICYDPOLICYSQL}"

/opt/zimbra/bin/mysql policyd_db < "${POLICYDPOLICYSQL}"

echo "Installing reporting command /usr/local/sbin/cbpolicyd-report (show message count by user/day)"
echo "/opt/zimbra/bin/mysql policyd_db -e \"select count(instance) count, sender from session_tracking where date(from_unixtime(unixtimestamp))=curdate() group by sender order by count desc;\"" > /usr/local/sbin/cbpolicyd-report
chmod +rx /usr/local/sbin/cbpolicyd-report

echo "Setting up cbpolicyd database clean-up daily at 03:35AM in /etc/cron.d/cbpolicyd-cleanup"
echo "35 3 * * * zimbra bash -l -c '/opt/zimbra/cbpolicyd/bin/cbpadmin --config=/opt/zimbra/conf/cbpolicyd.conf --cleanup' >/dev/null" > /etc/cron.d/cbpolicyd-cleanup

echo "To activate your configuration, run as zimbra user:
zmprov ms \$(zmhostname) +zimbraServiceEnabled cbpolicyd
zmprov ms \$(zmhostname) zimbraCBPolicydQuotasEnabled TRUE
zmcontrol restart

You can find logging here:
tail -f /opt/zimbra/log/cbpolicyd.log"
