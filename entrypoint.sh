#!/bin/sh

# Setting up configuration for phabricator db connection and mail  
sed -e "s/PHABRICATOR_HOST/$PHABRICATOR_HOST/g" \
  -e "s/MYSQL_HOST/"$MYSQL_HOST"/g" \
  -e "s/MYSQL_USER/"$MYSQL_USER"/g" \
  -e "s/MYSQL_PASS/"$MYSQL_PASS"/g" \
  -e "s/AWS_SES_ACCESS_KEY/"$AWS_SES_ACCESS_KEY"/g" \
  -e "s/AWS_SES_SECRET_KEY/"$AWS_SES_SECRET_KEY"/g" \
  -e "s/AWS_SES_REGION/"$AWS_SES_REGION"/g" \
  -i /opt/phabricator/conf/local/local.json

if [ "${1}" = "start-server" ]; then
  exec bash -c "/opt/phabricator/bin/storage upgrade --force; /opt/phabricator/bin/phd start; source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"
else
  exec $@
fi
