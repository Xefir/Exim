#!/usr/bin/env bash

echo "Username: "
read username
echo "Domain: "
read domain

userdbpw -md5 | userdb "$username@$domain" set systempw
makeuserdb
