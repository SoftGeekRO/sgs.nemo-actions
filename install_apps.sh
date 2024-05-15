#!/bin/bash
######################################################
# SoftGeek Romania Nemo actions dependencies install #
######################################################

source $(dirname $0)/lib.sh

is_root || { error "You are running this as regular user. Run as root" >&2; exit $E_NOTROOT; }

USAGE="Usage: $SCRIPT_NAME {all | install | uninstall | reinstall | installBulky}"

Help() {
   notice "Available options for installing sgs.nemo-actions"
   notice
   notice "Syntax: ./install.sh [all|install|uninstall|reinstall|installBulky|uninstallBulky|listPackages]"
   notice "options:"
   notice "all            Install all packages and Bulky."
   notice "install        Install only the default packages without Bulky"
   notice "uninstall      Uninstall the default packages"
   notice "reinstall      Reinstall the packages and install again"
   notice "installBulky   Build and install Bulky from sources"
   notice "uninstallBulky Remove Bulky from system"
   notice "listPackages   Show a list of what packages are going to be installed"
   notice
}

listPackages() {
  printList $(cat packages.list)
}

installPythonPackages() {
  info "Install all the Python packages"
  pip install -r requirements.txt
}

installPackages() {
  info "Installing the must-have pre-requisites"
  RED='\033[0;37m'
  NC='\033[0m'
  while read -r package; do
    info "${package} - ${RED}$(packageInfo ${package})${NC}"
    DEBIAN_FRONTEND=noninteractive
    apt install -yqq -o=Dpkg::Use-Pty=0 ${package} 2>/dev/null >/dev/null
  done < <(cat packages.list)
}

removePackages() {
  apt -yq remove $(cat packages.list) 2>/dev/null >/dev/null
}

installBulky() {
  info "Install necessary apps for build the Bulky..."
  apt install -y git dpkg-dev debhelper python3-magic 2>/dev/null >/dev/null

  info "Clone the Bulky repository"
  git clone https://github.com/linuxmint/bulky.git /tmp/bulky 2>/dev/null >/dev/null

  cd /tmp/bulky/
  dpkg-buildpackage -uc -us 2>/dev/null >/dev/null
  dpkg -i ../bulky*.deb 2>/dev/null >/dev/null
  info "Cleanup after bulky clone and build"
  rm -R /tmp/bulky
}

removeBulky() {
  apt remove -y bulky 2>/dev/null >/dev/null
}

case "$1" in
  all)
    info "Install all the packages for Nemo actions and Bulky"
    installPythonPackages
    installPackages
    installBulky
  ;;
  install)
    info "Install all the packages for Nemo actions"
    installPythonPackages
    installPackages
  ;;
  uninstall)
    removePackages
  ;;
  reinstall)
    removePackages
    installPackages
  ;;
  installBulky)
    info "Build and install the Bulky app"
    installBulky
  ;;
  uninstallBulky)
    info "Uninstall Bulky from the system"
    removeBulky
  ;;
  listPackages)
    listPackages
  ;;
  *)
  Help
  exit 1
  ;;
esac