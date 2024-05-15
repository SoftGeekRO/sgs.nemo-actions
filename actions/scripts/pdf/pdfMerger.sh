#!/bin/bash

echo ">>> $@" >/dev/pts/0;

OUTPUTFILE=""
SOURCE_FILES=()
DELETESOURCE=FALSE

dir=`dirname "$1"`

scriptdir=$(dirname $(dirname $(readlink -f "${BASH_SOURCE[0]}")))

# import the config file
source "$scriptdir/config.ini"

# check if any langauge var is set if not, en.ini is set
lang="${MDM_LANG%_*}"

langdir="$scriptdir/lang"
if [ -f "$langdir/$lang.ini" ];
  then
    source "$langdir/$lang.ini"
  else
    source "$langdir/en.ini"
fi

formatOuputfile() {
  local combined_filenames=""

  _IFS=$IFS
  IFS=","
  for f in $@; do
    SOURCE_FILES+=( """'"$f"'""" )
    base_name=`basename -- "$f"`
    fname="${base_name%.*}"

    fname_noextension=`echo "$fname" | sed 's| |_|g'`
    combined_filenames+="${fname_noextension}_" # poor man's join of strings
  done
  IFS=$_IFS

  OUTPUTFILE="${combined_filenames%?}" # remove the last _character
}

configDialog() {
  OUTPUT=$(yad --title="$merge_config_title" --form --separator="," \
      --geometry 500x100 \
      --field="$merge_config_out_filename:" \
      --field="$merge_config_delete_sources::CB" \
      $OUTPUTFILE \
      'Accept\!^Deny' \
    ) accepted=$?

  if ((accepted == 0)); then
    OUTPUTFILE=$(echo $OUTPUT | awk 'BEGIN {FS="," } { print $1 }' | tr -d '[:space:]')
    DELETESOURCE=$(echo $OUTPUT | awk 'BEGIN {FS="," } { print $2 }' | tr -d '[:space:]')
  fi
}

mergeFiles() {
  pdftk "$1" cat output "$dir/$OUTPUTFILE.pdf" verbose
}

formatOuputfile "$@"

configDialog || exit $?

#mergeFiles "$@1" || exit $?

pdftk "$@" cat output "$dir/$OUTPUTFILE.pdf" verbose