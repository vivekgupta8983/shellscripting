
 # Check if running as root  
 if [ "$(id -u)" != "0" ]; then  
   echo "This script must be run as root" 1>&2  
   exit 1  
 fi 
   # create database in MySQL
  # replace "-" with "_" for database username
    echo "Please enter database name"
    read DBNAME
    echo "please enter the database username"
    read DBuser
    echo "Please enter root user MySQL password!"
    read rootpasswd
    echo "Please enter DB user MySQL password!"
    read PASSWDDB

    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${DBuser}@localhost IDENTIFIED BY '${PASSWDDB}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBuser}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
    

 