# How-to use Sieve filters on Zimbra

This article is a short how-to on using Sieve Filters on Zimbra. Sieve is a powerful scripting language for filtering incoming email messages. While Zimbra supports user set incoming email filters, the Sieve filters are meant to be set-up and installed by administrators. 

First you want to allow the adding of email headers, which is useful for debugging your filter scripts:

      zmprov mc default zimbraSieveEditHeaderEnabled TRUE

Then create a text file with your Sieve script. In this example we use `/tmp/myfilters`:

```
require ["fileinto", "reject", "tag", "flag", "editheader"];

# add an external domain header to all email not coming from our own domains
if allof(
  not address :domain :is ["from"] ["example.org", "lists.example.org", "otherdomain.nl"]
)
{
  addheader "X-External-Domain" "Warning come from external domain";
}

# restrict anyone that uses example.com to mail to a domain that is not example.nl, but allow mailing to info2@example.com. To notify the sender in case the mail is rejected. Instead of `reject`, you can use `discard`. Discard will not tell the sender the email was not delivered
if allof(
  address :domain :is ["from"] ["example.com"],
  not address :domain :is ["to"] ["example.nl"],
  not address :is ["cc", "to"] ["info2@example.com"]
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

      cat /tmp/myfilters |xargs -0 zmprov ma info@example.com zimbraAdminSieveScriptBefore

You can set `zimbraAdminSieveScriptBefore` per account,cos,domain,server. If you set it on an a domain and on an account in that domain, the script on the account is used. To unset `zimbraAdminSieveScriptBefore`  on an account you can do:

      zmprov ma info@example.com zimbraAdminSieveScriptBefore ""
