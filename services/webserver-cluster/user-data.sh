#!/bin/bash
cat > /var/www/html/index.html <<EOF
<h1>This is a Great Day</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

sudo yum -y install httpd
sudo chkconfig --add  httpd
sudo service httpd start
sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo service http restart
