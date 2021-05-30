#!/bin/bash

crontab -u root -r
dos2unix /tmp/crontab.txt
crontab -u root /tmp/crontab.txt

cd /var/www/html/var
mv classes classes_old
ln -s /storage/var/classes classes
if [ $? -eq 0 ]; then
    echo "Successfully created classes symlink"
fi
mv tmp tmp_old
ln -s /storage/var/tmp tmp
if [ $? -eq 0 ]; then
    echo "Successfully created classes symlink"
fi
mv config config_old
ln -s /storage/var/config config
if [ $? -eq 0 ]; then
    echo "Successfully created config symlink"
fi
cd /var/www/html/var
mv versions versions_old
ln -s /storage/var/versions .
if [ $? -eq 0 ]; then
    echo "Successfully created versions symlink"
fi
mv sessions sessions_old
mkdir sessions
#ln -s /storage/var/sessions .
#if [ $? -eq 0 ]; then
#    echo "Successfully created sessions symlink"
#fi

cd /var/www/html/web
rm -rf var
ln -s /storage/web-var var
if [ $? -eq 0 ]; then
    echo "Successfully created classes symlink"
fi

cd /var/www/html/var
cp -rf classes_old/* classes/
rm -rf classes_old
cp -rf config_old/* config/
rm -rf config_old
rm -rf versions_old
rm -rf tmp_old
rm -rf sessions_old

rm -rf cache
ls -la

cd /var/www/html
php -d memory_limit=-1 bin/console pimcore:deployment:classes-rebuild -c
php -d memory_limit=-1 bin/console pimcore:deployment:classes-rebuild -d -q
php -d memory_limit=-1 bin/console assets:install --symlink web
php -d memory_limit=-1 bin/console cache:clear
php -d memory_limit=-1 bin/console pimcore:migrations:migrate -s app -n
php -d memory_limit=-1 bin/console pimcore:cache:clear

# Running Permissions
chown -R www-data:www-data /var/www/html/*
chmod -R 775 /var/www/html/*

/etc/init.d/stunnel4 restart
/etc/init.d/cron start

sudo bash -l /opt/microsoft/omsagent/bin/omsadmin.sh

cd /var/www/html
rm -rf .build-stage .build .build-prod

echo "Code Deployment Complete"


