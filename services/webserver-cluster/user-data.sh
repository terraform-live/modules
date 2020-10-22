#!/bin/bash
sudo yum -y install httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo yum -y install policycoreutils
sudo semanage port -a -t http_port_t -p tcp 8080
sudo semanage port -m -t http_port_t -p tcp 8080
sudo systemctl restart httpd
