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

install_tls_dkim() {
    mkdir -pv /etc/exim4/tls
    openssl req -x509 -newkey rsa -keyout /etc/exim4/tls/mail.key -out /etc/exim4/tls/mail.crt -days 4096 -nodes
    mkdir -pv /etc/exim4/dkim
    openssl genrsa -out /etc/exim4/dkim/private.key 2048
}

install_exim() {
    install_ask_domain
    echo -e "${YEL}Two boxes will appear. Hit [Enter] each time to continue.${STD}"
    echo "Press [Enter] key to continue..."
    aptitude -y install exim4 courier-imap courier-imap-ssl courier-pop courier-pop-ssl courier-authlib-userdb ssl-cert
    chown -fvR daemon: courier/*
    cp -fv courier/* /etc/courier/
    chown -vR $USER: courier/*
    mkdir -pv /etc/exim.domains
    mkdir -pv /etc/exim.forward
    cp -fv exim4/* /etc/exim4/
    chmod -fv 777 /var/run/courier/authdaemon/socket
    install_tls_dkim
}

install_spamassassin() {
    aptitude -y install exim4-daemon-heavy sa-exim spamassassin
    cp -fv spamd/sa-learn /etc/cron.daily/sa-learn
    cp -fv spamd/spamassassin /etc/default/spamassassin
}

install_clamav() {
    aptitude -y install exim4-daemon-heavy clamav clamav-daemon
}

install_restart() {
    service courier-authdeamon restart
    service courier-imap restart
    service courier-pop restart
    service courier-imap-ssl restart
    service courier-pop-ssl restart
    service exim4 restart
}

install_mailserver() {
    echo "Do you want to install extra software ?"
    echo "1. None"
    echo "2. SpamAssassin (antispam)"
    echo "3. ClamAV (antivirus)"
    echo "4. Both SpamAssassin and ClamAV"
    echo "5. Exit"
    read -p "Enter choice [1 - 4] " choice
    case $choice in
        1) clear && install_exim && install_restart ;;
        2) clear && install_exim && install_spamassassin && install_restart ;;
        3) clear && install_exim && install_clamav && install_restart ;;
        4) clear && install_exim && install_spamassassin && install_clamav && install_restart ;;
        5) exit ;;
        *) clear && echo -e "${RED}Please enter a valid input${STD}" && install_mailserver ;;
    esac
}

clear && [[ $1 == "install" ]] && install_mailserver
