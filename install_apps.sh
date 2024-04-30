#!/bin/bash
######################################################
# SoftGeek Romania Nemo actions dependencies install #
######################################################

set -eu -o pipefail # fail on error and report it, debug all lines
trap 'cleanup; exit 1' HUP INT QUIT TERM

# E_NOTROOT=87 # Non-root exit error.
#
# [[ "$(id -u)" -eq 0 ]] && { error "You are running this as root. Run as regular user" >&2; exit $E_NOTROOT; }

sudo -n true
test $? -eq 0 || exit 1 "you should have sudo privilege to run this script"

echo installing the must-have pre-requisites
while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
    perl
    zip unzip
    exuberant-ctags
    mutt
    libxml-atom-perl
    postgresql-9.6
    libdbd-pgsql
    curl
    wget
    libwww-curl-perl
EOF
)

echo installing the nice-to-have pre-requisites
echo you have 5 seconds to proceed ...
echo or
echo hit Ctrl+C to quit
echo -e "\n"
sleep 6

sudo apt-get install git dpkg-dev debhelper

cd ~/Downloads
git clone https://github.com/linuxmint/bulky.git
cd bulky/

dpkg-buildpackage -uc -us
sudo dpkg -i ../bulky*.deb
sudo apt -f install