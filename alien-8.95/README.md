# Proof of concept on how to build DEB/RPM Zimlet packages

        dnf install dpkg rpmrebuild
        
        dpkg-deb -b zmmboxsearchx
        ./alien.pl --to-rpm zmmboxsearchx.deb
        

One may debug using:
        
        rpmrebuild -pe zmmboxsearchx-20100625-2.noarch.rpm


Maintained by: Barry de Graaff <info@barrydegraaff.tk>
