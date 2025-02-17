#!/bin/bash

if [ ! -f /opt/mautic/cron/mautic ]; then

	cat <<EOF > /opt/mautic/cron/mautic
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
BASH_ENV=/tmp/cron.env

* * * * * php /var/www/html/bin/console mautic:segments:update 2>&1 | tee /tmp/stdout
EOF
fi

# register the crontab file for the www-data user
crontab -u www-data /opt/mautic/cron/mautic

# create the fifo file to be able to redirect cron output for non-root users
mkfifo /tmp/stdout
chmod 777 /tmp/stdout

# ensure the PHP env vars are present during cronjobs
declare -p | grep 'PHP_INI_VALUE_' > /tmp/cron.env

# run cron and print the output
cron -f | tail -f /tmp/stdout
