#!/bin/bash
sudo yum install httpd php php-mysqlnd php-json wget -y
sudo amazon-linux-extras install -y mariadb10.5 php8.2
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* /var/www/html/
sudo chown -R apache.apache /var/www/html
sudo systemctl start httpd