#!/bin/bash  
   
 ##################################################  
 # Bash script to install an LAMP stack in ubuntu #
 #          Author: Vivek Gupta                   #
 #        Contact: info@cloud2help.com            #
 ##################################################

 # Check if running as root  
 if [ "$(id -u)" != "0" ]; then  
   echo "This script must be run as root" 1>&2  
   exit 1  
 fi  
   
 # Update system  
 sudo apt-get update -y  
   
 ## Install Apache  
 sudo apt-get install apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert -y  
   
 ## Install PHP  
 apt-get install php libapache2-mod-php php-mysql -y  
   
 # Install MySQL database server  
 apt-get install mysql-server -y  
   
 # Enabling Mod Rewrite  
 sudo a2enmod rewrite headers 
 sudo php5enmod mcrypt  
   
 ## Install PhpMyAdmin  
 sudo apt-get install phpmyadmin -y  
   
 ## Configure PhpMyAdmin  
 echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf  
   
 # Set Permissions  
 sudo chown -R www-data:www-data /var/www  
   
 # Restart Apache  
 sudo systemctl restart  apache2
 sudo systemctl enable  apache2

 # Restart MySQL
 sudo systemctl restart mysql
 sudo systemctl enable mysql


 # Create a database named blog
mysqladmin -uroot create cloud2help


# Secure database
# non interactive mysql_secure_installation with a little help from expect.

SECURE_MYSQL=$(expect -c "
 
set timeout 10
spawn mysql_secure_installation
 
expect \"Enter current password for root (enter for none):\"
send \"\r\"
 
expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"password\r\"
expect \"Re-enter new password:\"
send \"password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
 
expect \"Disallow root login remotely?\"
send \"y\r\"
 
expect \"Remove test database and access to it?\"
send \"y\r\"
 
expect \"Reload privilege tables now?\"
send \"y\r\"
 
expect eof
")
 
echo "$SECURE_MYSQL"

# Change directory to web root
cd /var/www/html

# Download Wordpress
wget http://wordpress.org/latest.tar.gz

# Extract Wordpress
tar -xzvf latest.tar.gz

# Rename wordpress directory to blog
mv wordpress cloud2help

# Change directory to blog
cd /var/www/html/cloud2help/

# Create a WordPress config file 
cp wp-config-sample.php wp-config.php

#set database details with perl find and replace
sed -i "s/database_name_here/cloud2help/g" /var/www/html/cloud2help/wp-config.php
sed -i "s/username_here/root/g" /var/www/html/cloud2help/wp-config.php
sed -i "s/password_here/password/g" /var/www/html/cloud2help/wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 777 wp-content/uploads

#remove wp file
rm /var/www/html/latest.tar.gz

echo "Ready, go to http://'your ec2 url'/blog and enter the blog info to finish the installation."

bash vhost.sh 