#!/bin/sh

# if [ -z "${LOCAL_JSON}" ]; then
#   [ -z "${MYSQL_HOST}" ] && export MYSQL_HOST=""
#   [ -z "${MYSQL_USER}" ] && export MYSQL_USER=""
#   [ -z "${MYSQL_PASS}" ] && export MYSQL_PASS=""
  
sed -e "s/PHABRICATOR_HOST/$PHABRICATOR_HOST/g" \
  -e "s/MYSQL_HOST/"$MYSQL_HOST"/g" \
  -e "s/MYSQL_USER/"$MYSQL_USER"/g" \
  -e "s/MYSQL_PASS/"$MYSQL_PASS"/g" \
  -i /opt/phabricator/conf/local/local.json

sed -e "s/AWS_SES_ACCESS_KEY/"$AWS_SES_ACCESS_KEY"/g" \
    -e "s/AWS_SES_SECRET_KEY/"$AWS_SES_SECRET_KEY"/g" \
    -e "s/AWS_SES_REGION/"$AWS_SES_REGION"/g" \
    -i /opt/phabricator/conf/local/mailer.json 

/opt/phabricator/bin/config set --stdin cluster.mailers < /opt/phabricator/conf/local/mailer.json

# else
#   echo "${LOCAL_JSON}" > /opt/phabricator/conf/local/local.json
#   echo 
# fi

if [ "${1}" = "start-server" ]; then
  exec bash -c "/opt/phabricator/bin/storage upgrade --force; /opt/phabricator/bin/phd start; source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"
else
  exec $@
fi
