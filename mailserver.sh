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

install_exim_ask_domain() {
    echo -e "${GRE}Please enter the mail server's main domain${STD}"
    read choice
    [[ -n $choice ]] && echo $choice > /etc/mailname
    [[ -z $choice ]] && install_exim_ask_domain
}

install_exim() {
    install_exim_ask_domain
    echo -e "${YEL}Two boxes will appear. Hit [Enter] each time to continue.${STD}"
    echo "Press [Enter] key to continue..."
    aptitude -y install exim4 courier-imap courier-imap-ssl courier-pop courier-pop-ssl courier-authlib-userdb
    chown -vR daemon: courier/*
    cp -v courier/* /etc/courier
    chown -vR $USER: courier/*
}

install_spamassassin() {
    echo "lol"
}

install_clamav() {
    echo "lol"
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
        1) clear && install_exim ;;
        2) clear && install_exim && install_spamassassin ;;
        3) clear && install_exim && install_clamav ;;
        4) clear && install_exim && install_spamassassin && install_clamav ;;
        5) exit ;;
        *) clear && echo -e "${RED}Please enter a valid input${STD}" && install_mailserver ;;
    esac
}

clear && [[ $1 == "install" ]] && install_mailserver
