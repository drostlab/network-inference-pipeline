#!/bin/sh

# Usage:
#  infer_foreach_slice.sh <source> <sink> <command ...>
#
# This script will iterate all files named `counts_*.csv` in the <source>
# directory and call back <command> for each one. All arguments to this script
# trailing the first two (<source> and <sink>) will be considered part of
# <command>. When invoking <command>, source and target filenames will be
# appended as additional arguments, and the standard output streams will be
# redirected into logfiles. All output filenames will point into the <sink>
# directory, which will be created if it does not exist. Note that <command>
# will be invoked through `time` to measure runtimes.

set -e

BASE="$(pwd)"

if [ -z "$3" ]; then exit 1; fi
SOURCE="$1"
SINK="$2"
shift 2

cd "$SOURCE"
mkdir -p "$BASE/$SINK"

for f in counts_*.csv; do (
  cd $BASE
  set -x
  time $@ \
    $SOURCE/$f \
    "$SINK/network_$f" \
    >"$SINK/network_$f.stdout.log" \
    2>"$SINK/network_$f.stderr.log"
) done
