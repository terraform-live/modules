#!/bin/bash
/usr/bin/sudo yum -y install httpd
/usr/bin/sudo chkconfig --add  httpd
/usr/bin/sudo service httpd start
/usr/bin/sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

/bin/cat > index.html <<EOF
<h1>This is a Great Day</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

/usr/bin/sudo mv index.html /var/www/html/

/usr/bin/sudo service restart httpd
