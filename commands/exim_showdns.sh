#!/usr/bin/env bash

DNS=$(openssl rsa -in /etc/exim4/dkim.key -pubout)
DNS=$(echo ${DNS} | sed "s/ //g" | sed "s/.*Y-----\(.*\)-----E.*/\1/g")
echo -e '\t\t10800 IN MX 10 <domain>'
echo -e '\t\t10800 IN TXT "v=spf1 a -all"'
echo -e '_domainkey\t10800 IN TXT "o=~; r=postmaster@<domain>"'
echo -e "x._domainkey\t10800 IN TXT \"v=DKIM1; k=rsa; p=${DNS}\""
echo -e '_dmarc\t\t10800 IN TXT "v=DMARC1; p=quarantine"'
