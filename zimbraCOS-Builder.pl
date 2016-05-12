#!/usr/bin/perl
use strict;
use warnings;

#
# Keith McDermott (keithmcd@purdue.edu)
# 2014-02-03
#
# This script is designed to print out a chart showing all zimbra COS and which servers are associated with each
#
# This script should run from the LDAP master replica in a multi-server install.
#
# Yes, this is a perl script that calls outside apps often.  It was the easiest way to interface to Zimbra.
#
# You will need to add your Zimbra mailbox server names as a regex string on line 58 in place of HOSTNAMEREGEX.  E.g.: hostname[1-6][0-9]
# You will need to add your Zimbra server names as a regex on line 61 in place of HOSTNAMEWILDCARD.  E.g.: hostname.*.domain.com
# If needed, you may want to adjust the printf formatting in the print* subs to better suit your naming convention lengths.

# DEBUGGING: Set to 0 to turn it off, 1 to turn it on
my $DEBUG = 0;

my %HOSTS;
my %COS;

init();

sub init
{
	#Set initial code and then begin
	getCOS();
	getHosts();

	printChart();
}

sub getCOS
{
	#Get all of the COS in the Zimbra environment
	my $tmpCOS = qx(su - zimbra -c "zmprov gac");
	foreach my $line (split /[\r\n]+/, $tmpCOS)
	{
		#Get all the hosts assigned with this specific COS
		print "Working with COS: $line\n" if $DEBUG;
		
		#Get a list of all of the hosts in the pool.  
		# These will be hostId entries.
		# Later, we can correlate these to the "friendly" hostnames.
		my $hostPool = qx(su - zimbra -c "zmprov gc $line zimbramailhostpool" | grep "zimbraMailHostPool" | cut -d: -f2);
		print "Host pool: $hostPool\n" if $DEBUG;
		$COS{$line} = $hostPool;
	}
}

sub getHosts
{
	#Get all of the Zimbra mailbox hosts in the enivronment

	my $tmpHosts = qx(su - zimbra -c 'zmprov gas -v -e' | egrep "cn:|zimbraId:" | paste - - | egrep "HOSTNAMEREGEX");
	foreach my $line (split /[\n\r]+/, $tmpHosts)
	{
		my $host = $1 if $line =~ /(HOSTNAMEWILDCARD)/;
		my $hostID = $1 if $line =~ /zimbraId: (.*)/;
		print "Found: $host, $hostID\n" if $DEBUG;
		
		$HOSTS{$host} = $hostID;
	}
}

sub printChart
{
	printHeader();
	#Iterate through each mailbox server.  Print which Zimbra COS it is in
	foreach my $host ( sort keys %HOSTS )
	{
		print "Host: $host ($HOSTS{$host})\n" if $DEBUG;
		
		printf '%-28.27s', $host;
		checkHost( $HOSTS{$host} );
		print "\n";
	}
}

sub printHeader
{
	#Obviously, print a header line
	printf '%-28.27s', "Hostname";

        foreach ( sort keys %COS )
        {
		printf '%-8.7s', $_;
	}
	print "\n";

	#Next, loop through and print a line
	printf '%-28.27s', "------------------------------";

	foreach ( keys %COS )
	{
		printf '%-8.7s', "----------";
	}
	print "\n";
}

sub checkHost
{
	#When given a hostname, cross off which COS that host is in
	my $host = shift;
	foreach my $cos ( sort keys %COS )
	{
		print "Parsing $cos...\n" if $DEBUG;

		my %hostPool;
		foreach my $poolHost ( $COS{$cos} )
		{
			$poolHost =~ /.*$host.*/ ? printf '%-8.7s',"X" : printf '%-8.7s',"";
		}
	}
}
