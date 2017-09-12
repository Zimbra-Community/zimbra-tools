# Zimbra FOSS Search in XML Attachment 

Whenever you do a search in Zimbra Web Client, results also include plain/text attachments. Normally xml files are not shown in the result. This patch shows you how to enable Zimbra to include XML files in the search result.

Reference:
[https://wiki.zimbra.com/wiki/Disable_Indexing_for_Specific_File_Types](https://wiki.zimbra.com/wiki/Disable_Indexing_for_Specific_File_Types)

Before doing this, make a backup from ldap, and try on a test server first. Use at your own risk, without warranty of any kind.
Analyse and store the result of this command:

    su - zimbra
    source ~/bin/zmshutil; zmsetvars
    ldapsearch -x -H $ldap_master_url -D $zimbra_ldap_userdn -w $zimbra_ldap_password -b "cn=config,cn=zimbra" (zimbraMimeHandlerClass=*)"

The result is around 6 mime types that are registered, and XML is not one of them.
Create /tmp/xml.ldif with the following content:

    dn: cn=application/xml,cn=mime,cn=config,cn=zimbra
    cn: application/xml
    objectclass: zimbraMimeEntry
    zimbraMimeIndexingEnabled: TRUE
    zimbraMimeType: application/xml
    zimbraMimeFileExtension: xml
    zimbraMimeHandlerClass: TextPlainHandler
    description: Search in XML as if it was text

Then add this to Zimbra LDAP:

    zmlocalconfig -s zimbra_ldap_password
    ldapadd -x -h `zmhostname` -D uid=zimbra,cn=admins,cn=zimbra -W -f /tmp/xml.ldiff 
    
Verify the change with ldapsearch and then restart Zimbra with zmcontrol restart. You will probably need to re-do this on every upgrade of Zimbra (aka after you run the Zimbra installer).
