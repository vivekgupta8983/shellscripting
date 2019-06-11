#!/bin/bash
#  Lets ask some questions
     
echo "Enter a domain server (e.g. domain.com):";
read domain;
clear

echo "Enter a Alias (e.g. domain)"
read vhname
clear

echo "Enter SSL Certificate Path (e.g. certificate with .crt) "
read SSLCertificateFile

echo "Enter SSL private key Path (e.g. certificate with .key) "
read SSLCertificateKeyFile

echo "Enter SSL chain key Path (e.g. certificate with .ca.crt) "
read SSLCertificateChainFile


#  Create the file in /etc/apache2/sites-available

touch /etc/apache2/sites-available/${vhname}
#  setup a folder for the Error logs
mkdir /var/www/html/${vhname}

#  Check to see if you having a working folder in the document root

    echo "Do you have a folder for the website http://${vhname} in \"/var/www/html/\" already? (y/n)"
    read Question

#  Lets check the logic for the answer to the line above

        if [[ "${Question}" == "no" ]] || [[ "${Question}" == "n" ]]; then

            echo "What would you like to call the folder (no spaces or unusual characters) in /var/www/html/:";
            read NewFolder;

            clear

#  Create the new folder

            mkdir /var/www/html/${NewFolder}

#  Make sure we have the right permissions

            echo "To enable the correct folder permissions please enter the user (example: user):";
            read user;
            clear
            echo "Now enter the group (this could be \"nogroup\" example user:group):";
            read group;
            clear
            chmod -R 0644 /var/www/html/${NewFolder}
            chown -R ${user}:${group} /var/www/html/${NewFolder}

#  Insert the VirtualHost block into the file created /etc/apache2/sites-available

	    echo "
            #${vhname}.${domain}
	        <VirtualHost *:80>
		    ServerName ${vhname}
		    ServerAlias ${vhname}.${domain}
		    ServerAdmin admin@${vhname}
		    DocumentRoot /var/www/html/${NewFolder}/
		    <Directory /var/www/html/${NewFolder}/>
		            AllowOverride all
		            Order allow,deny
		            allow from all
		    </Directory>
	        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
		    <Directory "/usr/lib/cgi-bin">
		            AllowOverride None
		            Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		            Order allow,deny
		            Allow from all
		    </Directory>
            RewriteEngine On
            RewriteCond %{HTTPS} off
            RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI}	
            ErrorLog /var/www/domains/${vhname}/apache.error.log
            CustomLog /var/www/domains/${vhname}/apache.access.log common
            </VirtualHost>
        
         # SSL ${vhname}.${domain}
	        <VirtualHost *:443>
		    ServerName ${vhname}
		    ServerAlias ${vhname}.${domain}
		    ServerAdmin admin@${vhname}
		    DocumentRoot /var/www/html/${NewFolder}/
		    <Directory /var/www/html/${NewFolder}/>
		            AllowOverride all
		            Order allow,deny
		            allow from all
		   </Directory>
	    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
		    <Directory "/usr/lib/cgi-bin">
		            AllowOverride None
		            Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		            Order allow,deny
		            Allow from all
		    </Directory>
            SSLEngine on
            SSLCertificateFile ${SSLCertificateFile}
            SSLCertificateKeyFile ${SSLCertificateKeyFile}
            SSLCertificateChainFile ${SSLCertificateChainFile}                                                                                                                          
	    </VirtualHost>" >> /etc/apache2/sites-available/${vhname}
	    
#   If you have a folder already then do this 

        elif [[ "${Question}" == "yes" ]] || [[ "${Question}" == "y" ]]; then


	    echo "Please confirm and type the name of your folder in /var/www/html/ ?"
	    read ExistingFolder
		clear

#  Insert the VirtualHost block
            echo "        
	    ### ${vhname}.${domain}
	    <VirtualHost *:80>
		    ServerName ${vhname}
		    ServerAlias ${vhname}.${domain}
		    ServerAdmin admin@${vhname}
		    DocumentRoot /var/www/html/${ExistingFolder}/
		    <Directory /var/www/html/${ExistingFolder}/>
		            AllowOverride all
		            Order allow,deny
		            allow from all
		   </Directory>
	    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
		    <Directory "/usr/lib/cgi-bin">
		            AllowOverride None
		            Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		            Order allow,deny
		            Allow from all
		    </Directory>
            RewriteEngine On
            RewriteCond %{HTTPS} off
            RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI}	
            ErrorLog /var/www/domains/${vhname}/apache.error.log
            CustomLog /var/www/domains/${vhname}/apache.access.log common                                                                                
	    </VirtualHost>
        
         #${vhname}.${domain}
	        <VirtualHost *:443>
		    ServerName ${vhname}
		    ServerAlias ${vhname}.${domain}
		    ServerAdmin admin@${vhname}
		    DocumentRoot /var/www/html/${NewFolder}/
		    <Directory /var/www/html/${NewFolder}/>
		            AllowOverride all
		            Order allow,deny
		            allow from all
		    </Directory>
	        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
		    <Directory "/usr/lib/cgi-bin">
		            AllowOverride None
		            Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		            Order allow,deny
		            Allow from all
		    </Directory>	
            ErrorLog /var/www/domains/${vhname}/apache.error.log
            CustomLog /var/www/domains/${vhname}/apache.access.log common
            SSLEngine on
            SSLCertificateFile ${SSLCertificateFile}
            SSLCertificateKeyFile ${SSLCertificateKeyFile}
            SSLCertificateChainFile ${SSLCertificateChainFile}                                                                                                                          
	        </VirtualHost>
        " >> /etc/apache2/sites-available/${vhname}
        fi
                    

function progress(){
    echo -n "Testing configuration Please wait..."
	sleep 5
    while true
    do
         echo -n "."
         sleep 10
    done
    }

function dotest(){
    apache2ctl configtest
    echo ""
	sleep 5
	clear
    }

# Start it in the background
progress &

# Save PID
ME=$!

# Start the test
dotest

# Kill process
kill $ME &>/dev/null
clear
echo -n "...done."
sudo ln -s /etc/apache2/sites-available/${vhname} /etc/apache2/sites-enabled/${vhname}
clear
echo "Would you like me to restart the server? (y/n)"
read qServer
if [[ "${qServer}" == "yes" ]] || [[ "${qServer}" == "y" ]]; then
                     apache2ctl restart   
                echo "Apache Setup complete"
		
        elif [[ "${qServer}" == "no" ]] || [[ "${qServer}" == "n" ]]; then
            echo ""
fi
