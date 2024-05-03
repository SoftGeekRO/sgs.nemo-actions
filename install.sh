#!/bin/bash
############################################
# SoftGeek Romania Nemo actions collection #
############################################

source $(dirname $0)/lib.sh

[[ "$(id -u)" -eq 0 ]] && { error "You are running this as root. Run as regular user" >&2; exit $E_NOTROOT; }

CURRENT_USER="$(id -un)"
WORKING_DIR="$(dirname "$(readlink -f "$0")")"
BASENAME=$(basename $(pwd))
SCRIPT_NAME=$(basename "$0")

INSTALL_PATH="/home/${CURRENT_USER}/.local/share/nemo/actions"
NEMO_ACTIONS_SCRIPTS_DIR="${INSTALL_PATH}/scripts"

Help() {
   notice "Available options for installing sgs.nemo-actions"
   notice
   notice "Syntax: ./install.sh [install|uninstall|reinstall]"
   notice "options:"
   notice "install    Install only sgs.nemo-actions"
   notice "uninstall  Uninstall sgs.nemo-actions"
   notice "reinstall  Reinstall the sgs.nemo-actions"
   notice
}

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
    Help
    exit 1
    ;;
esac