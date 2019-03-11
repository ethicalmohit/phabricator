#!/bin/sh

if [ -z "${LOCAL_JSON}" ]; then
  [ -z "${MYSQL_HOST}" ] && export MYSQL_HOST="im-phabricatpr-dev.cnglqg9uvhy1.us-east-1.rds.amazonaws.com"
  [ -z "${MYSQL_USER}" ] && export MYSQL_USER="phab_user"
  [ -z "${MYSQL_PASS}" ] && export MYSQL_PASS="phab#!cat0r"
  

  # Patching the settings file.
  sed -e "s/{{MYSQL_HOST}}/${MYSQL_HOST}/g" \
    -e "s/{{MYSQL_USER}}/${MYSQL_USER}/g" \
    -e "s/{{MYSQL_PASS}}/${MYSQL_PASS}/g" \
    -i /opt/phabricator/conf/local/local.json
else
  echo "${LOCAL_JSON}" > /opt/phabricator/conf/local/local.json
fi

if [ "${1}" = "start-server" ]; then
  exec bash -c "/opt/phabricator/bin/storage upgrade --force; /opt/phabricator/bin/phd start; source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"
else
  exec $@
fi
