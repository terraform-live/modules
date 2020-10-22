#!/bin/bash
sudo apt update
sudo apt upgrade
sudo apt install nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo ufw allow http
sudo ufw enable
sed -i 's/80/8080/g' /etc/nginx/sites-enabled/default
sudo systemctl start nginx
