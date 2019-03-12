## Overview

This is an unofficial repository of phabricator by phacility.com docker image hosted at ethicalmohit/phabricator.

## Requirements (or Tested with)

Docker version 18.09.2, build 6247962

## Features

* Image building from scratch.
* Capability to pick database configurationf from environmental variable.
* Support for Amazon SES for outbound mails.
* Uses Latest PHP version.
* Support to change PHP.ini configuration from Dockerfile.
* Fetch current packages from phacility using commit ID.

## Image Building Steps

`docker build -t phabricator .`
`docker tag phabricator:latest ethicalmohit/phabricator:latest`
`docker push ethicalmohit/phabricator:latest`