#!/usr/bin/env sh
apk --no-cache add curl
curl --silent --fail http://app | grep 'PHP 8.3'
