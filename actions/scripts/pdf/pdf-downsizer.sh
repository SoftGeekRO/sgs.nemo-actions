#!/bin/bash

scriptdir=`dirname "$0"` ;

lang="${MDM_LANG%_*}" ;

zenity --info  \
  --title="$scriptdir" \
  --text="$lang" \
  --no-wrap ;