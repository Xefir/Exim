#!/usr/bin/env bash

echo "Forward FROM email: "
read emailfrom
echo "Forward TO email: "
read emailto

sed -i "s/$emailto,//g" "/etc/exim4/forward/$emailfrom"
