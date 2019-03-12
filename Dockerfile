#
# Docker image for running https://github.com/phacility/phabricator
#

FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install wget -y && \
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && \
echo "deb https://packages.sury.org/php/ jessie main" | tee /etc/apt/sources.list.d/php.list && \
apt-get install ca-certificates apt-transport-https -y

# TODO: review this dependency list
RUN apt-get update && apt-get install -y \
        git \
        vim \
        apache2 \
        curl \
        libapache2-mod-php7.3 \
        libmysqlclient18 \
        mercurial \
        mysql-client \
        php7.3-xml \
        php7.3-mbstring \
        php7.3 \
        php7.3-apcu \
        php7.3-cli \
        php7.3-curl \
        php7.3-gd \
        php7.3-json \
        php7.3-ldap \
        php7.3-mysql \
        python-pygments \
&& rm -rf /var/lib/apt/lists/*

# For some reason phabricator doesn't have tagged releases. To support
# repeatable builds use the latest SHA

ADD  download.sh /opt/download.sh

ARG  PHABRICATOR_COMMIT=40af472ff5
ARG  ARCANIST_COMMIT=9830c9316d
ARG  LIBPHUTIL_COMMIT=6c64dce5f7

WORKDIR  /opt

RUN  bash download.sh phabricator $PHABRICATOR_COMMIT
RUN  bash download.sh arcanist    $ARCANIST_COMMIT
RUN  bash download.sh libphutil   $LIBPHUTIL_COMMIT

# Setup apache

RUN  a2enmod rewrite

ADD  phabricator.conf /etc/apache2/sites-available/phabricator.conf

RUN  ln -s /etc/apache2/sites-available/phabricator.conf \
           /etc/apache2/sites-enabled/phabricator.conf && \
           rm -f /etc/apache2/sites-enabled/000-default.conf

# Setup phabricator
RUN  mkdir -p /opt/phabricator/conf/local /var/repo

ADD  local.json /opt/phabricator/conf/local/local.json

# Setup mailer
ADD  mailer.json /opt/phabricator/conf/local/mailer.json

#RUN  /opt/phabricator/bin/config set --stdin cluster.mailers < /opt/phabricator/conf/local/mailer.json

RUN  sed -e 's/post_max_size =.*/post_max_size = 32M/' \
        -e 's/upload_max_filesize =.*/upload_max_filesize = 32M/' \
        -e 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/' \
        -i /etc/php/7.3/apache2/php.ini

RUN  ln -s /usr/lib/git-core/git-http-backend /opt/phabricator/support/bin
RUN  /opt/phabricator/bin/config set phd.user "root"
RUN  echo "www-data ALL=(ALL) SETENV: NOPASSWD: /opt/phabricator/support/bin/git-http-backend" >> /etc/sudoers

#Help understanding phabricator that the request is served via HTTPS. 
#Ref: https://secure.phabricator.com/book/phabricator/article/configuring_preamble/
RUN  echo '<?php $_SERVER['HTTPS'] = true;' > /opt/phabricator/support/preamble.php

EXPOSE  80

ADD  entrypoint.sh /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]
CMD  ["start-server"]
