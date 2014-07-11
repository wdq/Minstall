#!/bin/bash
# Install (HTTP): Nginx

# Distribution Checks
check_repository_message "debian" "dotdeb" "DotDeb"
check_repository_message "ubuntu" "nginx"

# Package List Update Question
package_update_question

# Check OpenSSL
if ! check_package "openssl;"; then
	subheader "Installing OpenSSL..."
	package_install openssl
fi

# Install libssl for debian 7.

wget http://snapshot.debian.org/archive/debian/20110406T213352Z/pool/main/o/openssl098/libssl0.9.8_0.9.8o-7_amd64.deb
dpkg -i libssl0.9.8_0.9.8o-7_amd64.deb
rm libssl0.9.8_0.9.8o-7_amd64.deb

# Install Package
subheader "Installing Package..."
package_install nginx

# Copy Configuration
subheader "Copying Configuration..."
cp -rf $MODULEPATH/$MODULE/etc/* /etc/

# Create Caching Directory
subheader "Creating Caching Directory..."
mkdir -p /var/lib/nginx/cache
chown -R www-data:www-data /var/lib/nginx/cache
chmod -R o= /var/lib/nginx/cache

# Create Self Signed SSL Certificate
subheader "Creating Self Signed SSL Certificate..."
openssl req -new -days 3650 -newkey rsa:2048 -nodes -x509 -subj "/C=/ST=/L=/O=/CN=$(hostname -f)" -out /etc/nginx/ssl.d/self.pem -keyout /etc/nginx/ssl.d/self.key
chown -R www-data:www-data /etc/nginx/ssl.d
chmod -R o= /etc/nginx/ssl.d

# Set Distribution Specific Variables
if [ $DISTRIBUTION = "debian" ]; then
	string_replace_file /etc/nginx/sites-available/default.conf "root path" "root /usr/share/nginx/html"
	string_replace_file /etc/nginx/sites-available/system.conf "root path" "root /usr/share/nginx/html"
elif [ $DISTRIBUTION = "ubuntu" ]; then
	string_replace_file /etc/nginx/sites-available/default.conf "root path" "root /usr/share/nginx/www"
	string_replace_file /etc/nginx/sites-available/system.conf "root path" "root /usr/share/nginx/www"
fi

# Common Clean
common-clean

# Restart Daemon
subheader "Restarting Daemon..."
daemon_manage nginx restart
