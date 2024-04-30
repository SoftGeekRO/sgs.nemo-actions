#!/bin/bash
############################################
# SoftGeek Romania Nemo actions collection #
############################################

E_NOTROOT=87 # Non-root exit error.

[[ "$(id -u)" -eq 0 ]] && { error "You are running this as root. Run as regular user" >&2; exit $E_NOTROOT; }

CURRENT_USER="$(id -un)"
WORKING_DIR="$(dirname "$(readlink -f "$0")")"
BASENAME=$(basename $(pwd))
SCRIPT_NAME=$(basename "$0")

USAGE="Usage: $SCRIPT_NAME {install | uninstall | reinstall}"

INSTALL_PATH="/home/${CURRENT_USER}/.local/share/nemo/actions"
NEMO_ACTIONS_SCRIPTS_DIR="${INSTALL_PATH}/scripts"

# Fancy red-colored `error` function with `stderr` redirection with `exit`.
error () {
    { printf '\E[31m'; echo ":: $@"; printf '\E[0m'; } >&2
}

info() {
  { printf '\E[32m'; echo ":: $1"; printf '\E[0m'; } >&2
}

notice() {
  { printf '\E[33m'; echo ":: $1"; printf '\E[0m'; } >&2
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

case "$1" in
  install)
    info "Install sgs.nemo-actions on current user profile: $CURRENT_USER"

    if ! [ -d "$INSTALL_PATH" ]; then
      error "The Nemo actions folder is not found in user home folder"
      error "Check if you have Nemo installed"
      exit 1
    fi

    info "Create soft links for Nemo actions"
    for action in ${WORKING_DIR}/actions/*.nemo_action; do
        filename=$(basename ${action})
        if ! [[ -h "${INSTALL_PATH}/${filename}" ]]; then
            ln -s "${action}" "${INSTALL_PATH}/${filename}"
        fi
    done

    info "Check if any Nemo actions scripts folder exists"
    if ! [[ -d ${NEMO_ACTIONS_SCRIPTS_DIR} ]]; then
        mkdir -p ${NEMO_ACTIONS_SCRIPTS_DIR}
    fi

    info "Create soft links for scripts used on Nemo actions and make scripts executable for the user"
    for script in ${WORKING_DIR}/actions/scripts/*; do
        chmod 744 ${script}
        filename=$(basename ${script})
        if ! [[ -h "${NEMO_ACTIONS_SCRIPTS_DIR}/${filename}" ]]; then
            ln -s "${script}" "${NEMO_ACTIONS_SCRIPTS_DIR}/${filename}"
        fi
    done

    ;;
  uninstall)
    info "Remove the soft links from Nemo actions"
    for action in ${INSTALL_PATH}/*.nemo_action; do
        if [ -h "${action}" ] && readlink -f "${action}" | grep -q "${WORKING_DIR}"; then
            rm ${action}
        fi
    done

    info "Remove the soft links for Nemo actions scrips"
    for action in ${NEMO_ACTIONS_SCRIPTS_DIR}/*; do
      if [ -h "${action}" ] && readlink -f "${action}" | grep -q "${WORKING_DIR}"; then
        rm ${action}
      fi
    done

    _scripts=$( shopt -s nullglob ; set -- $NEMO_ACTIONS_SCRIPTS_DIR/* ; echo $#)
    if [[ $_scripts -eq "0" ]]; then
        rm -R ${NEMO_ACTIONS_SCRIPTS_DIR}
    fi

    ;;
  reinstall)
    ./"$0" uninstall
    ./"$0" install
  ;;
  *)
    echo $USAGE
    exit 1
    ;;
esac