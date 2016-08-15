#!/usr/bin/env bash

usage(){
    echo "usage: ./mailserver.sh [help] [install]"
    echo "help: show this help"
    echo "install: install exim/courier mail server"
}

RED="\e[91m"
GRE="\e[92m"
YEL="\e[93m"
STD="\e[0m"

[[ $# -lt 1 ]] && usage
[[ $1 == "help" ]] && usage
[[ $EUID -ne 0 ]] && echo -e "${RED}This script must be run as root.${STD}" && exit 1

install_ask_domain() {
    echo -e "${GRE}Please enter the mail server's main domain${STD}"
    read choice
    [[ -n $choice ]] && echo $choice > /etc/mailname
    [[ -z $choice ]] && install_ask_domain
}

install_exim() {
    install_ask_domain
    echo -e "${YEL}Two boxes will appear. Hit [Enter] each time to continue.${STD}"
    read -p "Press [Enter] key to continue..."
    aptitude -y install exim4 courier-imap courier-imap-ssl courier-authlib-userdb ssl-cert
    chown -fvR daemon: courier/*
    cp -fv courier/* /etc/courier/
    chown -vR $USER: courier/*
    mkdir -pv /etc/exim.domains
    mkdir -pv /etc/exim.forward
    cp -fv exim4/exim4.conf /etc/exim4/exim4.conf
    chmod -fv 777 /var/run/courier/authdaemon/socket
    /usr/share/doc/exim4-base/examples/exim-gencert
    openssl genrsa -out /etc/exim4/dkim.key 2048
    install_restart
    gen_public_dns
}

install_spamassassin() {
    aptitude -y install exim4-daemon-heavy sa-exim spamassassin
    cp -fv spamd/sa-learn /etc/cron.daily/sa-learn
    cp -fv spamd/spamassassin /etc/default/spamassassin
    systemctl enable spamassassin
    service spamassassin restart
    install_restart
}

install_clamav() {
    aptitude -y install exim4-daemon-heavy clamav clamav-daemon
    adduser clamav Debian-exim
    systemctl enable clamav-daemon
    service clamav-daemon restart
    install_restart
}

install_restart() {
    service courier-authdeamon restart
    service courier-imap restart
    service courier-pop restart
    service courier-imap-ssl restart
    service courier-pop-ssl restart
    service exim4 restart
}

gen_public_dns() {
    DNS=$(sudo openssl rsa -in /etc/exim4/dkim.key -pubout)
    DNS=$(echo ${DNS} | sed "s/ //g" | sed "s/.*Y-----\(.*\)-----E.*/\1/g")
    echo -e "${YEL}Please put these pointers on your DNS provider :${STD}"
    echo -e '\t\t10800 IN MX 10 <domain>'
    echo -e '\t\t10800 IN TXT "v=spf1 a -all"'
    echo -e '_domainkey\t10800 IN TXT "o=~; r=postmaster@<domain>"'
    echo -e "x._domainkey\t10800 IN TXT \"v=DKIM1; k=rsa; p=${DNS}\""
    echo -e '_dmarc\t\t10800 IN TXT "v=DMARC1; p=quarantine"'
    read -p "Press [Enter] key to continue..."
}

install_mailserver() {
    echo "Do you want to install extra software ?"
    echo "1. None"
    echo "2. SpamAssassin (antispam)"
    echo "3. ClamAV (antivirus)"
    echo "4. Both SpamAssassin and ClamAV"
    echo "5. Show DNS config"
    echo "6. Exit"
    read -p "Enter choice [1 - 6] " choice
    case $choice in
        1) install_exim ;;
        2) install_exim && install_spamassassin ;;
        3) install_exim && install_clamav ;;
        4) install_exim && install_spamassassin && install_clamav ;;
        5) gen_public_dns ;;
        6) exit ;;
        *) clear && echo -e "${RED}Please enter a valid input${STD}" && install_mailserver ;;
    esac
}

clear && [[ $1 == "install" ]] && install_mailserver
