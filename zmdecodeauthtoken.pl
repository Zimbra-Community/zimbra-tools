#!/usr/bin/perl
# Decode a zimbraAuthToken
use v5.18;
use strict;
use warnings;
no warnings qw(experimental::smartmatch);
use POSIX qw(strftime);
unless (eval {
  require Data::Dumper::Concise;
  Data::Dumper::Concise->import;
  1;
}) {
  require Data::Dumper;
  Data::Dumper->import;
}

my $token = $ARGV[0] || die "Usage: $0 token";

my @token = split(/_/, $token);
die "Invalid format: Wrong number of parts" if (scalar @token != 3);

my %token = (
  'key-id'    => $token[0],
  'hmac-sha1' => $token[1], # src/java/com/zimbra/cs/account/TokenUtil.java
  'data'      => $token[2],
);

my @metadata = split(/;/, pack("H*", $token{'data'}));
my %metadata;
my %keys = ( # src/java/com/zimbra/cs/account/ZimbraAuthToken.java
  id => 'account-id', # uuid
  aid => 'admin-account-id', # uuid
  exp => 'expires', # millitime
  admin => 'is-admin', # bool
  da    => 'is-domain-admin', # bool
  dlgadmin => 'is-delegated-admin',
  type  => 'account-type', # [zimbra, external]
  am => 'auth-mech', # [zimbra, ldap, ad, kerberos5, custom] (src/java/com/zimbra/cs/account/auth/AuthMechanism.java)
  u => 'usage-code', # [a => AUTH, etfa => ENABLE_TWO_FACTOR_AUTH, tfa => TWO_FACTOR_AUTH], default AUTH (src/java/com/zimbra/cs/account/AuthToken.java)
  email => 'external-user-email',
  digest => 'external-user-digest',
  vv => 'validity-value', # int, default -1, zimbraAuthTokenValidityValue
  tid => 'token-id', # random int, default -1
  version => 'server-version', # string
  csrf => 'csrf-token-enabled', # bool
);
foreach my $metadata (@metadata) {
  my($key, $length, $data) = split(/[=:]/, $metadata, 3);
  $key = $keys{$key} || "unknown-$key";
  given ($key) {
    $data = strftime('%Y-%m-%d %H:%M:%S', localtime($data / 1000)) when 'expires';
  }
  $metadata{$key} = $data;
}

$token{'data'} = \%metadata;

print Dumper(\%token);
