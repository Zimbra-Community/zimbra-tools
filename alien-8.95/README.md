# Proof of concept on how to build DEB/RPM Zimlet packages

        dnf install dpkg rpmrebuild
        
        dpkg-deb -b pgp-zimlet
        ./alien.pl --to-rpm pgp-zimlet.deb
        

One may debug using:
        
        rpmrebuild -pe pgp-zimlet-2.0.7-2.noarch.rpm


Maintained by: Barry de Graaff <info@barrydegraaff.tk>
