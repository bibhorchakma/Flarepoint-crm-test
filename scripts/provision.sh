#!/bin/bash

# Script to Setup LEMP Stack on Ubuntu Server.
# Developed by Soikat Chakma (soikat@hood.ai)

# Update package installer
sudo apt-get update
# Install nginx
sudo apt-get install nginx -y

# Update APT
sudo apt update

# Install php and mySql. Not sure if Ruby required???
sudo apt install -y php7.0 php7.0-mbstring php7.0-xml php7.0-zip php7.0-mysql git software-properties-common python-software-properties python-pip wget nodejs

# Upgrade dependencies
sudo apt upgrade -y

# Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php -- --install-dir=/usr/bin --filename=composer
rm composer-setup.php

# Configure PHP processor: Set cgi.fix_pathinfo=0 in php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini

# Configure Nginx to use PHP Processor. File Name: /etc/nginx/sites-available/default
: 'server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
} '
# 1. Change the starting point of Nginx; it looks for the index.php, which is located in public folder.
#		root /var/www/public;
# 2. Add index.php to the list of allowed file types to deliver by default: index index.php index.html index.htm index.nginx-debian.html;
# 3. Add server ip address example: server_name 52.91.253.85;
# 4. Tell Nginx to use php-fpm which we installed. Just uncomment the second location block
		# 	location ~ \.php$ {
        # 		include snippets/fastcgi-php.conf;
        #		fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    	#	}
# 5. Tell Nginx to to ignore/deny .httaccess file. This is used for Apache server. Uncomment the third location block
		#   location ~ /\.ht {
        #		deny all;
    	#	}


echo "server {" > /etc/nginx/sites-available/default
echo "        listen 80 default_server;" >> /etc/nginx/sites-available/default
echo "        listen [::]:80 default_server;" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        root /var/www/public;" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        index index.php index.html;" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        server_name _;" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        location / {" >> /etc/nginx/sites-available/default
echo "                try_files \$uri \$uri/ /index.php;" >> /etc/nginx/sites-available/default
echo "        }" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        location ~* (index)\.php\$ {" >> /etc/nginx/sites-available/default
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "                fastcgi_pass unix:/run/php/php7.0-fpm.sock;" >> /etc/nginx/sites-available/default
echo "        }" >> /etc/nginx/sites-available/default
echo "" >> /etc/nginx/sites-available/default
echo "        location ~ /\.ht {" >> /etc/nginx/sites-available/default
echo "                deny all;" >> /etc/nginx/sites-available/default
echo "        }" >> /etc/nginx/sites-available/default
echo "}" >> /etc/nginx/sites-available/default

# Check Nginx configuration file syntax
sudo nginx -t

# Restart php and nginx
sudo service php7.0-fpm reload
sudo service nginx reload

# Remove default web directory
sudo rm -rf /var/www/html

echo "Congrats Your LEMP Stack installation finished"

###### Setup for AWS Codedeploy ######
# Install Ruby
sudo apt-get install -y ruby
# Install AWS CLI
pip install awscli

# Install AWS codedeploy agent. USE your region
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
rm -rf install
