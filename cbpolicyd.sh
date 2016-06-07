#!/bin/bash
set -e
# if you want to trace your script uncomment the following line
# set -x


# Documentation used from https://www.zimbrafr.org/forum/topic/7623-poc-zimbra-policyd/
# https://wiki.zimbra.com/wiki/Postfix_Policyd#Example_Configuration

# enhancement check package manager to choose between yum or aptitude

echo "Automated cbpolicd installer for single-server Zimbra 8.6 on CentOS 6 or 7"

# CentOS 7
yum -y groupinstall MariaDB\ Database\ Client
# CentOS 6
yum -y groupinstall MySQL\ Database\ client
yum install -y epel-release 
yum install -y pwgen

rm policyd-master* -Rf

wget "https://gitlab.devlabs.linuxassist.net/policyd/policyd/repository/archive.zip?ref=master" -O cbpolicyd-archive.zip
unzip cbpolicyd-archive.zip

CBPOLICYD_PWD=$(pwgen 10 -N1)

# creating a user, just to make sure we have one (for mysql on CentOS 6, so we can execute the next mysql queries w/o errors)
cat <<EOF > /tmp/policyd-install.sql
CREATE DATABASE policyd_db CHARACTER SET 'UTF8'; 
CREATE USER 'ad-policyd_db'@'127.0.0.1' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'127.0.0.1' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

# need enhancement here with the use of zimbra env settings avoiding zmlocalconfig command
mysql --force --host=127.0.0.1 --port=7306 --user=root --password=$(su zimbra -c "/opt/zimbra/bin/zmlocalconfig -s | grep mysql | grep ^mysql_root_password" | awk '{print $3}') < /tmp/policyd-install.sql > /dev/null 2>&1

<<EOF > /tmp/policyd-install.sql
DROP USER 'ad-policyd_db'@'127.0.0.1';
DROP DATABASE IF EXISTS policyd_db;
CREATE DATABASE policyd_db CHARACTER SET 'UTF8'; 
CREATE USER 'ad-policyd_db'@'127.0.0.1' IDENTIFIED BY '${CBPOLICYD_PWD}'; 
GRANT ALL PRIVILEGES ON policyd_db . * TO 'ad-policyd_db'@'127.0.0.1' WITH GRANT OPTION; 
FLUSH PRIVILEGES ; 
EOF

# need enhancement here with the use of zimbra env settings avoiding zmlocalconfig command
cat /tmp/policyd-install.sql
mysql --host=127.0.0.1 --port=7306 --user=root --password=$(su zimbra -c "/opt/zimbra/bin/zmlocalconfig -s | grep mysql | grep ^mysql_root_password" | awk '{print $3}') < /tmp/policyd-install.sql

echo "For your reference the database policyd_db and user have been created using: /tmp/policyd-install.sql"

cd policyd-master*/database/

for i in core.tsql access_control.tsql quotas.tsql amavis.tsql checkhelo.tsql checkspf.tsql greylisting.tsql accounting.tsql; 
	do 
	./convert-tsql mysql $i;
	done > /tmp/policyd.sql

echo "Backing up /opt/zimbra/conf/cbpolicyd.conf.in in /tmp/"
cp -a /opt/zimbra/conf/cbpolicyd.conf.in /tmp/cbpolicyd.conf.in.$(date +%s)

echo "Please wait... policyd_db populating..."
# need enhancement here with the use of zimbra env settings avoiding zmlocalconfig command
mysql --host=127.0.0.1 --port=7306 --user=root --password=$(su zimbra -c "/opt/zimbra/bin/zmlocalconfig -s | grep mysql | grep ^mysql_root_password" | awk '{print $3}') policyd_db < /tmp/policyd.sql
echo "For your reference the database policyd_db populated using: /tmp/policyd.sql"

echo "Setting username in /opt/zimbra/conf/cbpolicyd.conf.in:"
grep -lZr -e ".*sername=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in" | xargs -0 sed -i "s^.*sername=.*$^Username=ad-policyd_db^g"

echo "Setting password in /opt/zimbra/conf/cbpolicyd.conf.in:"
grep -lZr -e ".*assword=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in"  | xargs -0 sed -i "s^.*assword=.*$^Password=${CBPOLICYD_PWD}^g"

echo "Setting database in /opt/zimbra/conf/cbpolicyd.conf.in:"
grep -lZr -e "DSN=.*$" "/opt/zimbra/conf/cbpolicyd.conf.in"  | xargs -0 sed -i "s^DSN=.*$^DSN=DBI:mysql:database=policyd_db;host=127.0.0.1;port=7306^g"

cat <<EOF > /tmp/policyd-policy.sql
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
/tmp/policyd-policy.sql"

mysql --host=127.0.0.1 --port=7306 --user=root --password=$(su zimbra -c "/opt/zimbra/bin/zmlocalconfig -s | grep mysql | grep ^mysql_root_password" | awk '{print $3}') policyd_db < /tmp/policyd-policy.sql

echo "Setting up cbpolicyd database clean-up daily at 03:35AM in /etc/cron.d/cbpolicyd-cleanup"
echo "35 3 * * * zimbra bash -l -c '/opt/zimbra/cbpolicyd/bin/cbpadmin --config=/opt/zimbra/conf/cbpolicyd.conf --cleanup' >/dev/null" > /etc/cron.d/cbpolicyd-cleanup

echo "To activate your configuration, run as zimbra user:
zmprov ms \$(zmhostname) +zimbraServiceEnabled cbpolicyd 
zmprov ms \$(zmhostname) zimbraMtaEnableSmtpdPolicyd TRUE
zmprov ms \$(zmhostname) zimbraCBPolicydQuotasEnabled TRUE
zmcontrol restart

You can find logging here:
/opt/zimbra/log/cbpolicyd.log"
