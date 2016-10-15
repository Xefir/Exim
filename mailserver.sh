#!/usr/bin/env bash

RED="\e[91m"
GRE="\e[92m"
YEL="\e[93m"
STD="\e[0m"

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
    aptitude -y install exim4 courier-imap courier-imap-ssl courier-authlib-userdb ssl-cert sudo openssl
    mkdir -pv /etc/exim4/domains
    mkdir -pv /etc/exim4/forward
    cp -fv exim4/exim4.conf /etc/exim4/exim4.conf
    chmod -fv 777 /var/run/courier/authdaemon
    chmod -fv 777 /var/run/courier/authdaemon/socket
    /usr/share/doc/exim4-base/examples/exim-gencert
    openssl genrsa -out /etc/exim4/dkim.key 2048
    openssl dhparam -out /etc/courier/dhparams.pem 2048
    install_restart
}

install_spamassassin() {
    aptitude -y install exim4-daemon-heavy sa-exim spamassassin pyzor razor
    sudo -u debian-spamd pyzor discover
    razor-admin -home=/etc/razor -discover
    cp -fv spamd/sa-learn /etc/cron.daily/sa-learn
    cp -fv spamd/spamassassin /etc/default/spamassassin
    [[ -n $(which systemctl) ]] && systemctl enable spamassassin
    service spamassassin restart
    install_restart
}

install_clamav() {
    aptitude -y install exim4-daemon-heavy clamav clamav-daemon
    adduser clamav Debian-exim
    [[ -n $(which systemctl) ]] && systemctl enable clamav-daemon
    service clamav-daemon restart
    install_restart
}

install_restart() {
    service courier-authdeamon restart
    service courier-imap restart
    service courier-imap-ssl restart
    service exim4 restart
}

install_mailserver() {
    echo "Do you want to install extra software ?"
    echo "1. None"
    echo "2. SpamAssassin (antispam)"
    echo "3. ClamAV (antivirus)"
    echo "4. Both SpamAssassin and ClamAV"
    echo "5. Exit"
    read -p "Enter choice [1 - 5] " choice
    case $choice in
        1) install_exim ;;
        2) install_exim && install_spamassassin ;;
        3) install_exim && install_clamav ;;
        4) install_exim && install_spamassassin && install_clamav ;;
        5) exit ;;
        *) clear && echo -e "${RED}Please enter a valid input${STD}" && install_mailserver ;;
    esac
}

clear && install_mailserver
