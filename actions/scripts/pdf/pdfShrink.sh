#!/bin/bash

IMG_RESOLUTION="72"
GRAYSCALE="NO"
PDF_VERSION="1.5"
OVERWRITE_FORMAT="subfix"
OVERWRITE_FILENAME=""

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

# Get the file's directory
filedir=`dirname "$1"`
iFile="$filedir/$fname_basename"
fname_subfix="$filedir/$fname_name_subfix"
fname_datetime="$filedir/$fname_name_datetime"

configDialog() {
  OUTPUT=$(yad --title="$pdfShrink_config_title" --form --separator="," \
    --geometry 400x100 \
    --field="$pdfShrink_config_field_grayscale:CHK" \
    --field="$pdfShrink_config_field_image_quality::CB" \
    --field="$pdfShrink_config_field_shrink_filename::CB" \
    '' \
    'Low\!^Medium\!High' \
    'DateTime\!^Subfix' \
  ) accepted=$?

  if ((accepted == 0)); then
    GRAYSCALE=$(echo $OUTPUT | awk 'BEGIN {FS="," } { print $1 }' | tr -d '[:space:]')
    resolution=$(echo $OUTPUT | awk 'BEGIN {FS="," } { print $2 }' | tr -d '[:space:]')
    shrinkFormat=$(echo $OUTPUT | awk 'BEGIN {FS="," } { print $3 }' | tr -d '[:space:]')

    case $resolution in
      "Low")
        IMG_RESOLUTION="72"
      ;;
      "Medium")
        IMG_RESOLUTION="150"
      ;;
      "High")
        IMG_RESOLUTION="300"
      ;;
    esac

    case $shrinkFormat in
      "DateTime")
        SHRINK_FILENAME="$fname_datetime"
      ;;
      "Subfix")
        SHRINK_FILENAME="$fname_subfix"
      ;;
    esac

  else
    return 0
  fi
}

# downsize the file
shrink() {
  if [ "$4" == "TRUE" ]; then
    gray_params="-sProcessColorModel=DeviceGray \
                   -sColorConversionStrategy=Gray \
                   -dOverrideICC"
  else
    gray_params=""
  fi

  # Allow unquoted variables; we want word splitting for $gray_params.
  # shellcheck disable=SC2086
  ghostscript					                    \
    -q -dNOPAUSE -dBATCH -dSAFER		      \
    -sDEVICE=pdfwrite			                \
    -dCompatibilityLevel="$5"		          \
    -dPDFSETTINGS=/screen			            \
    -dEmbedAllFonts=true			            \
    -dSubsetFonts=true			              \
    -dAutoRotatePages=/None		            \
    -dColorImageDownsampleType=/Bicubic	  \
    -dColorImageResolution="$3"		        \
    -dGrayImageDownsampleType=/Bicubic	  \
    -dGrayImageResolution="$3"		        \
    -dMonoImageDownsampleType=/Subsample	\
    -dMonoImageResolution="$3"		        \
    -sOutputFile="$2"			                \
    ${gray_params}			                  \
    "$1"
}

get_pdf_version () {
	# $1 is the input file. The PDF version is contained in the
	# first 1024 bytes and will be extracted from the PDF file.
	PDF_VERSION=$(cut -b -1024 "$1" | LC_ALL=C awk 'BEGIN { found=0 }{ if (match($0, "%PDF-[0-9]\\.[0-9]") && ! found) { print substr($0, RSTART + 5, 3); found=1 } }')
	if [ -z "$PDF_VERSION" ] || [ "${#PDF_VERSION}" != "3" ]; then
		return 1
	fi
}

check_smaller () {
	# If $1 and $2 are regular files, we can compare file sizes to
	# see if we succeeded in shrinking. If not, we copy $1 over $2:
	if [ ! -f "$1" ] || [ ! -f "$2" ]; then
		return 0;
	fi
	ISIZE="$(wc -c "$1" | awk '{ print $1 }')"
	OSIZE="$(wc -c "$2" | awk '{ print $1 }')"
	if [ "$ISIZE" -lt "$OSIZE" ]; then
	  zenity --error  \
	    --title="$shrink_check_smaller_title" \
	    --text="$shrink_check_smaller_text" \
	    --no-wrap
	  rm "$2"
	fi
}

configDialog || exit $?

# Get the PDF version of the input file.
get_pdf_version "$iFile"

# # Shrink the PDF.
shrink "$iFile" "$SHRINK_FILENAME" "$IMG_RESOLUTION" "$GRAYSCALE" "$PDF_VERSION" || exit $?

# Check that the output is actually smaller.
check_smaller "$iFile" "$SHRINK_FILENAME"