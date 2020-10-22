#!/bin/bash
sudo yum install httpd
sudo apt upgrade
sudo apt install nginx
sudo systemctl enable httpd
sudo systemctl start httpd
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo yum install policycoreutils
sudo semanage port -a -t http_port_t -p tcp 8080
sudo semanage port -m -t http_port_t -p tcp 8080
sudo systemctl restart httpd
