# To attach Intellij debugger to the Zimbra instance:

1. Open the 'Run/Debug Configuration' panel in Intellij
2. Create a new 'Remote' configuration
3. Copy the line 'Command line arguments for running remote JVM', we will refer it as **intellij options row**
4. Then on the server as zimbra: `zmcontrol stop`
5. As root: cp /opt/zimbra/libexec/zmmailboxdmgr /opt/zimbra/libexec/zmmailboxdmgr.old 
6. As root: cp /opt/zimbra/libexec/zmmailboxdmgr.unrestricted /opt/zimbra/libexec/zmmailboxdmgr 
7. nano /opt/zimbra/conf/localconfig.xml find the key mailboxd_java_options and _append_ to the value line **intellij options row** 
8. As zimbra: zmcontrol start
9. if you have a host firewall:  firewall-cmd --add-port=5005/tcp

10. As of Zimbra 8.8.12 Java 9.0 JDWP supports only local connections by default. You need to add `*:` before the address

Here is an example result:

    <key name="mailboxd_java_options">
    <value>-server -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djava.awt.headless=true -Dsun.net.inetaddr.ttl=${networkaddress_cache_ttl} -Dorg.apache.jasper.compiler.disablejsr199=true -XX:+UseConcMarkSweepGC -XX:SoftRefLRUPolicyMSPerMB=1 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStoppedTime -XX:-OmitStackTraceInFastThrow -Xloggc:/opt/zimbra/log/gc.log -XX:-UseGCLogFileRotation -XX:NumberOfGCLogFiles=20 -XX:GCLogFileSize=4096K -Djava.net.preferIPv4Stack=true -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005</value>
