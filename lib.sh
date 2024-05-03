#!/bin/bash
##############################
# SoftGeek Romania bash lib  #
##############################

E_NOTROOT=87 # Non-root exit error.

is_root() {
  [[ $(id -u) -eq 0 ]]
}

error () {
  { printf '\E[31m'; echo -e ":: $@"; printf '\E[0m'; } >&2
}

info() {
  { printf '\E[32m'; echo -e ":: $1"; printf '\E[0m'; } >&2
}

notice() {
  { printf '\E[33m'; echo -e ":: $1"; printf '\E[0m'; } >&2
}

printList() {
   { printf '\E[35m'; printf "> %s\n" ${@}; printf '\E[0m'; } >&2
}

packageInfo() {
  dpkg-query -W --showformat='${Version} (${db:Status-Status})' $1
}

cleanup() {
  err=$?
  info "Cleaning stuff up..."
  trap '' EXIT INT TERM
  exit $err
}
sig_cleanup() {
  trap '' EXIT # some shells will call EXIT after the INT handler
  false # sets $?
  error "Force exit from script..."
  cleanup
}
trap 'cleanup; exit 1' EXIT
trap sig_cleanup HUP INT QUIT TERM