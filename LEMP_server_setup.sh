
#!/bin/bash

# SCRIPT TO SETUP LEMP STACK IN UBUNTU 16.04.
# DEVELOPED BY SOIKAT CHAKMA

##-------- INSTALL NODE AND NPM --------------##
curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs -y
sudo apt-get install build-essential

# Installing yarn
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn



##------------ INSTALL NGINX SERVER --------------##
sudo apt-get update
sudo apt-get install nginx -y

##------------ INSTALL MYSQL SERVER --------------##

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password your_password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password your_password'
sudo apt-get install mysql-server -y
mysql_secure_installation

##------------ INSTALL PHP7.2 --------------##
# SETUP PHP 7.2
# Enable PPA

sudo apt-get update
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

# Install PHP 7.2
sudo apt-get install php7.2 -y

# Install necessary PHP modules
sudo apt-get install php7.2-fpm php7.2-xml php7.2-common php7.2-mysql php7.2-mbstring php7.2-gd php7.2-curl composer unzip -y

# Configure PHP processor: Set cgi.fix_pathinfo=0 in php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.2/fpm/php.ini

# restart the service to take effect 
sudo systemctl restart php7.2-fpm

### Finished PHP Setup ######

# Configure Nginx to use the PHP processor. We have to change it in Nginx server block configuration file(Similar
# to Apache's virtual hosts). The file is : /etc/nginx/sites-available/default
: '  server {
        listen 80;
        listen [::]:80;
        root /var/www/html/hood/public;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name 54.157.196.65;

        location / {
                try_files $uri $uri/ /index.php?$query_string;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
    } '

# 1. Add index.php as the first value of our index directive.
# 2. We can modify the server_name directive to pint our server's domain name or public IP address.
# 3. For the actual PHP processing, we just need to uncomment a segment of the file that handles PHP 
#		requests by removing the pound symbols (#) from in front of each line. 
#		This will be the location ~\.php$ location block, the included fastcgi-php.conf snippet, 
#		and the socket associated with php-fpm.
# 4. We will also uncomment the location block dealing with .htaccess files using the same method. 
# 		Nginx doesn't process these files. If any of these files happen to find their way into the 
# 		document root, they should not be served to visitors. 


echo "server {" > /etc/nginx/sites-available/hood.crm
echo "        listen 80;" >> /etc/nginx/sites-available/hood.crm
echo "        listen [::]:80;" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        root /var/www/html/hood/public;" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        index index.php index.html;" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        server_name _;" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        location / {" >> /etc/nginx/sites-available/hood.crm
echo "                try_files $uri $uri/ /index.php?$query_string;" >> /etc/nginx/sites-available/hood.crm
echo "        }" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-available/hood.crm
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "                fastcgi_pass unix:/run/php/php7.2-fpm.sock;" >> /etc/nginx/sites-available/hood.crm
echo "        }" >> /etc/nginx/sites-available/hood.crm
echo "" >> /etc/nginx/sites-available/hood.crm
echo "        location ~ /\.ht {" >> /etc/nginx/sites-available/hood.crm
echo "                deny all;" >> /etc/nginx/sites-available/hood.crm
echo "        }" >> /etc/nginx/sites-available/hood.crm
echo "}" >> /etc/nginx/sites-available/hood.crm


# After making changes we need to reload Nginx to make the necessary changes
sudo systemctl reload nginx


#### Finished infrastructure

## Configure MYSQL
# login to root account
mysql -u root -p

CREATE DATABASE crm DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

#. Create user that al;lowed to access the database
GRANT ALL ON crm.* TO 'hood'@'localhost' IDENTIFIED BY 'hood2018';

# Flush the privileges to notify the MySQL server of the changes.
FLUSH PRIVILEGES;
EXIT;

##--------- Setup for AWS Codedeploy -------------##
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
















