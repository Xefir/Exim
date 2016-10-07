#!/usr/bin/env bash

echo "Forward FROM email: "
read emailfrom
echo "Forward TO email: "
read emailto

DIR=/etc/exim4/forward
sed -i "s/$emailto,//g" "$DIR/$emailfrom"
[[ ! -s $DIR/$emailfrom ]] && rm -f $DIR/$emailfrom
