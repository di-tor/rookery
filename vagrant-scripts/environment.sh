#!/usr/bin/env bash


# Add Timezone Support To MySQL

#mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=$1 mysql

#database
mysql -uroot -p$1 -e 'create database if not exists rookery;'


block="
    server {
        listen 80;
        root /vagrant/public;
        index index.html index.htm index.php;

        server_name rookery.dev 192.168.33.30.xip.io;
        access_log /var/log/nginx/rookery-access.log;
        error_log  /var/log/nginx/rookery-error.log error;
        charset utf-8;
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        location /api {
            try_files \$uri \$uri/ /api.php?\$query_string;
        }
        location /admin {
            try_files \$uri \$uri/ /admin.php?\$query_string;
        }
        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt  { access_log off; log_not_found off; }
        # pass the PHP scripts to php5-fpm
        # Note: .php$ is susceptible to file upload attacks
        # Consider using: \"location ~ ^/(index|app|app_dev|config).php(/|$) {\"
        location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # With php5-fpm:
            fastcgi_pass unix:/run/php/php7.0-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param HTTP_PROXY \"\";
            fastcgi_param HTTPS off;
        }
        # Deny .htaccess file access
        location ~ /\.ht {
            deny all;
        }
        location ~* \.html$ {
            expires -1;
        }
        location ~* \.(css|js|gif|jpe?g|png)$ {
            expires 1M;
            add_header Pragma public;
            add_header Cache-Control \"public, must-revalidate, proxy-revalidate\";
        }
        gzip on;
        gzip_http_version 1.1;
        gzip_vary on;
        gzip_comp_level 6;
        gzip_proxied any;
        gzip_types application/atom+xml \
                   application/javascript \
                   application/json \
                   application/vnd.ms-fontobject \
                   application/x-font-ttf \
                   application/x-web-app-manifest+json \
                   application/xhtml+xml \
                   application/xml \
                   font/opentype \
                   image/svg+xml \
                   image/x-icon \
                   text/css \
                   text/html \
                   text/plain \
                   text/xml;
        gzip_buffers 16 8k;
        gzip_disable \"MSIE [1-6]\.(?!.*SV1)\";
    }
"

echo "$block" | sudo tee /etc/nginx/sites-available/rookery
sudo ln -s /etc/nginx/sites-available/rookery /etc/nginx/sites-enabled/rookery
sudo service nginx restart

###########

cd /vagrant
composer install