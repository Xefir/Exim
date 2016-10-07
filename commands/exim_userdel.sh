#!/usr/bin/env bash

echo "Username: "
read username
echo "Domain: "
read domain

DIR=/etc/exim4/domains
sed -i "/$username/d" "$DIR/$domain"
[[ ! -s $DIR/$domain ]] && rm -f $DIR/$domain
userdb "$username@$domain" del
makeuserdb
