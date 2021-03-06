#!/bin/bash
# Simple script for the flexextract docker image. It does argument checking and
# then runs the image. If the script is run from cron then it appends its
# output to a logfile.
#
# When this script is deployed in production it will be run by a wrapper
# ('flexextract') which sets the correct environment variables.

set -Eueo pipefail

if [[ $# -lt 3 ]]
then
    >&2 printf "usage: flexextract startdate enddate controlfile \n"
    exit 1
fi

# When stdin is not a tty - i.e when run from cron - save output to a log file.
if [[ ! -t 0  ]]
then
    exec >> "$HOME/run.log"
    exec 2>&1
    echo -n "=== starting flexextract "; date
fi

SDATE="$1"
EDATE="$2"
CFILE="$3"
TAG="${TAG:-flexextract}"
HOST_DIR="${HOST_DIR:-/tmp/flexextract_download}"
CONT_DIR="${CONT_DIR:-/usr/local/Flexpart_9.0.3/download/}"

# Try not to clobber the download directories when running multiple copies.
EXISTING=$(docker ps -a -f ancestor="$TAG" -q)
if [[ -n "$EXISTING" ]]; then
   >&2 echo "Another flexextract run is in progress (with id $EXISTING)."
   exit 1
fi

set -x

time docker run --rm -t --init            \
       -v/etc/localtime:/etc/localtime:ro \
       -v"$HOST_DIR":"$CONT_DIR"          \
       -eSDATE="$SDATE"			          \
       -eEDATE="$EDATE"                   \
       -eCFILE="$CFILE"			          \
       -eDOWNLOADPATH="$CONT_DIR"         \
       "$TAG" bash -c 'python3 $FLEXEXTRACTPATH/submit.py       \
							  --start_date=$SDATE               \
							  --end_date=$EDATE                 \
                              --controlfile=$CONTROLPATH/$CFILE \
                              --inputdir="$DOWNLOADPATH"'

