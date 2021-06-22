# Example Sieve filters for Zimbra 9

Short how-to on using Sieve Filters on Zimbra. In case you want to add email headers:

      zmprov mc default zimbraSieveEditHeaderEnabled TRUE

Put a your sieve script in `/tmp/myfilters` example:

```
require ["fileinto", "reject", "tag", "flag", "editheader"];

# add an external domain header to all email not coming from our own domains
if allof(
  not address :domain :is ["from"] ["zetalliance.org", "lists.zetalliance.org", "barrydegraaff.nl"]
)
{
  addheader "X-External-Domain" "Warning come from external domain";
}

# restrict anyone that uses barrydegraaff.tk to mail to a domain that is not barrydegraaff.nl, but allow mailing to info2@barrydegraaff.tk. To notify the sender in case the mail is rejected. Instead of `reject`, you can use `discard`. Discard will not tell the sender the email was not delivered
if allof(
  address :domain :is ["from"] ["barrydegraaff.tk"],
  not address :domain :is ["to"] ["barrydegraaff.nl"],
  not address :is ["cc", "to"] ["info2@barrydegraaff.tk"]
)
{
  reject "sorry gautam does not allow you to email";
  stop;
}
```

Some more examples:

```
# filter based on any header containing barry, put it in the barry folder
if anyof (header :contains "from" "barry" )
{
    addheader "X-MyBarry-Header" "itsdabom";
    fileinto "barry";
    stop;
}

#Filter email based on a subject
if header :contains "Subject" [
  "Logwatch"
  ]
{
    fileinto "Logwatch";
    stop;
}

#Filter based on a custom header, that indicates email was forwarded via a rule in outlook.com
if header :contains "X-MS-Exchange-Inbox-Rules-Loop" [
  "user@hotmail.com"
  ]
{
    fileinto "forwarded-from-outlook";
    stop;
}

# If you do not like sendgrid, you can move it to Junk based on the Return-Path
if header :contains "Return-Path" [
  "sendgrid.net"
  ]
{
    fileinto "Junk";
    stop;
}

#Not doing business in any of these countries, you can use wildcard 
if address :domain :matches ["From"] ["*.za", "*.pe","*.sg","*.id","*.mk","*.cn","*.ua"]
{
  fileinto "Junk";
  stop;
}

```

Apply the filters to an account like this:

      cat /tmp/myfilters |xargs -0 zmprov ma info@barrydegraaff.tk zimbraAdminSieveScriptBefore

zimbraAdminSieveScriptBefore can be set per account,cos,domain,server.
