# To attach Intellij debugger to the Zimbra instance:

1. Open the 'Run/Debug Configuration' panel in Intellij
2. Create a new 'Remote' configuration
3. Copy the line 'Command line arguments for running remote JVM', we will refer it as <intellij options row>

The on the server:
as zimbra:
4. zmcontrol stop

as root:
5. cp /opt/zimbra/libexec/zmmailboxdmgr /opt/zimbra/libexec/zmmailboxdmgr.old 
6. cp /opt/zimbra/libexec/zmmailboxdmgr.unrestricted /opt/zimbra/libexec/zmmailboxdmgr 

7. nano /opt/zimbra/conf/localconfig.xml
find the key mailboxd_java_options and append to the value <intellij options row> 

as zimbra:
8. zmcontrol start

if you have a host firewall: 
9. firewall-cmd --add-port=5005/tcp

Here is an example result:

    <key name="mailboxd_java_options">
    <value>-server -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djava.awt.headless=true -Dsun.net.inetaddr.ttl=${networkaddress_cache_ttl} -Dorg.apache.jasper.compiler.disablejsr199=true -XX:+UseConcMarkSweepGC -XX:SoftRefLRUPolicyMSPerMB=1 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStoppedTime -XX:-OmitStackTraceInFastThrow -Xloggc:/opt/zimbra/log/gc.log -XX:-UseGCLogFileRotation -XX:NumberOfGCLogFiles=20 -XX:GCLogFileSize=4096K -Djava.net.preferIPv4Stack=true -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005</value>
