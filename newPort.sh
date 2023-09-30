#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NOCOLOR='\033[0m'
PORTCHECKBOOL=false

echo WELCOME TO PORT CONFIGURATOR [POCO]
echo PORT CONFIGURATOR v.09/30/2023
while [ "$PORTCHECKBOOL" != "true" ];
  do
    echo Type in your port-number
    read PORTNUMBER
    echo You entered Port:${BLUE} $PORTNUMBER ${NOCOLOR}
    echo checking file exists:
    FILEPATH=/etc/nginx/sites-available/$PORTNUMBER
    if [ -f "$FILEPATH" ];
    then
      echo ${RED}The file already exists, try another port-number ${NOCOLOR}
    else 
      echo ${GREEN}Port is avaiable ${NOCOLOR}
      PORTCHECKBOOL=true
    fi
  done

NGINXCONFIG='
server {\n
        listen '$PORTNUMBER';\n
        listen [::]:'$PORTNUMBER';\n
        root /var/www/'$PORTNUMBER';\n
        index index.html index.htm index.php;\n
\n
        #error_log /var/www/'$PORTNUMBER'/logs/error.log;\n
        #access_log /var/www/'$PORTNUMBER'/logs/access.log;\n
\n
        server_name _;\n
        location / {\n
                try_files $uri $uri/ /index.php?$args;\n
                #try_files $uri $uri/ =404;\n
        }\n
        location ~ \.php$ {\n
                try_files $uri =404;\n
                fastcgi_split_path_info ^(.+\.php)(/.+)$;\n
                fastcgi_pass unix:/run/php/php8.1-fpm.sock;\n
                fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;\n
                fastcgi_index index.php;\n
                include fastcgi_params;\n
                fastcgi_read_timeout 9000;\n
                fastcgi_send_timeout 9000;\n
        }\n
        location ~ /\.ht {\n
                deny all;\n
        }\n
}\n'

echo $NGINXCONFIG > $FILEPATH
echo nginx config created
sudo cp $FILEPATH /etc/nginx/sites-enabled/$PORTNUMBER
echo sites avaiable linked to sites-enabled
mkdir /var/www/$PORTNUMBER
PHPTESTFILE=/var/www/10500/index.php
echo '<?php phpinfo();' > $PHPTESTFILE
echo created php test file

sudo chown -R www-data:www-data /var/www/
sudo chmod -R 777 /var/www/
echo changed user rights
systemctl restart nginx
echo restarted nginx
echo ${GREEN}"Port created succesfully ${NOCOLOR}