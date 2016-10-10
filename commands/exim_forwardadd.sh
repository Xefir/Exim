#!/usr/bin/env bash

echo "Forward FROM email: "
read emailfrom
echo "Forward TO email: "
read emailto

DIR=/etc/exim4/forward
echo "$([[ -f $DIR/$emailfrom ]] && cat $DIR/$emailfrom)$emailto," > "$DIR/$emailfrom"
