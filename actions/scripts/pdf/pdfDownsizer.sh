#!/bin/bash

res="72"
grayscale="YES"

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
iFile="$filedir/$filename_basename"
oFile="$filedir/$filename_name_subfix"

# backup the original file
cp "$iFile" "$oFile"
# delete the original file
rm "$iFile"

get_pdf_version () {
	# $1 is the input file. The PDF version is contained in the
	# first 1024 bytes and will be extracted from the PDF file.
	pdf_version=$(cut -b -1024 "$1" | LC_ALL=C awk 'BEGIN { found=0 }{ if (match($0, "%PDF-[0-9]\\.[0-9]") && ! found) { print substr($0, RSTART + 5, 3); found=1 } }')
	if [ -z "$pdf_version" ] || [ "${#pdf_version}" != "3" ]; then
		return 1
	fi
}

# downsize the file
shrink() {
  if [ "$grayscale" = "YES" ]; then
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
      -dCompatibilityLevel="$4"		          \
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

check_overwrite () {
	# If $1 and $2 refer to the same file, then the file would get
	# truncated to zero, which is unexpected. Abort the operation.
	# Unfortunately the stronger `-ef` test is not in POSIX.
	if [ "$1" = "$2" ]; then
	  zenity --error width=500 --title="$downsize_overwrite_title" --text="$downsize_overwrite_text"
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
		echo "Input smaller than output, doing straight copy" >&2
		cp "$1" "$2"
	fi
}

# Check that the output file is not the same as the input file.
check_overwrite "$oFile" "$iFile" || exit $?

# Get the PDF version of the input file.
get_pdf_version "$oFile" || pdf_version="1.5"

# Shrink the PDF.
shrink "$oFile" "$iFile" "$res" "$pdf_version" || exit $?

# Check that the output is actually smaller.
check_smaller "$ifile" "$ofile"

# zenity --info  \
#   --title="$finished_title" \
#   --text="$downsize_finished_text" \
#   --no-wrap