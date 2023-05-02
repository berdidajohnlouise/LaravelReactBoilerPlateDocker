#!/bin/sh -e

if [ $1 = "prod" ]; then 
    cp /var/www/api/env.production /var/www/api/.env
elif [ $1 = "dev" ]; then
    cp /var/www/api/env.development /var/www/api/.env
    cp /var/www/client/env.development /var/www/client/.env
else
    cp /var/www/api/env.local /var/www/api/.env
fi 