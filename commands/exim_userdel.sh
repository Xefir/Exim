#!/usr/bin/env bash

echo "Username: "
read username
echo "Domain: "
read domain

sed "/$username/d" "/etc/exim4/domains/$domain"
userdb "$username@$domain" del
makeuserdb
