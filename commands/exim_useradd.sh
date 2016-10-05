#!/usr/bin/env bash

echo "Username: "
read username
echo "Domain: "
read domain

echo "$username" >> "/etc/exim4/domains/$domain"
echo "Password: "
userdb "$username@$domain" set uid=$(id -u mail) gid=$(id -g mail) home="/var/vmail/$domain/$username" mail="/var/vmail/$domain/$username"
userdbpw -md5 | userdb "$username@$domain" set systempw
makeuserdb
