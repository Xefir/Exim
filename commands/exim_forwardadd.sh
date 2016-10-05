#!/usr/bin/env bash

echo "Forward FROM email: "
read emailfrom
echo "Forward TO email: "
read emailto

echo "$(cat /etc/exim4/forward/$emailfrom)$emailto," > "/etc/exim4/forward/$emailfrom"
