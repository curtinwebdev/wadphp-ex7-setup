#!/bin/bash
echo "setting up database ..."
cat ./repo/setup/database.sql | sudo mysql -u root
echo "database created"
echo "creating db users ..."
cat ./repo/setup/dbusers.sql | sudo mysql -u root
echo "users created"
echo "cleaning up ..."
rm -rf README.md
rm -rf ./repo/setup
mv ./repo/* ./
rm -rf ./repo
echo "setting permissions ..."
sudo adduser $USER www-data
sudo chown -R $USER:www-data /home/ubuntu/environment
sudo find /home/ubuntu/environment -type d -exec chmod 775 {} \;
echo "updating apache ports ..."
sudo service apache2 stop
sudo sed -ir '/Listen/{s/\([0-9]\+\)/8080/; :a;n; ba}' /etc/apache2/ports.conf
echo "updating sites-enabled ..."
sudo sed -i 's+*:80>+*:8080>+g' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i 's+DocumentRoot /var/www/html+DocumentRoot /home/ubuntu/environment+g' /etc/apache2/sites-enabled/000-default.conf
echo "updating apache2.conf ..."
sudo sed -i 's+<Directory /var/www/>+<Directory /home/ubuntu/environment/>+g' /etc/apache2/apache2.conf
sudo service apache2 restart
echo "all done!"
sudo rm -rf ./setup.sh
