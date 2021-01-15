#!/bin/sh

# Usage:
#  foreach_slice.sh <source> <sink> <logs> <command ...>
#
# This script will iterate all files named `network_*.csv` in the <source>
# directory and call back <command> for each one. All arguments to this script
# trailing the first three (<source>, <sink> and <logs>) will be considered
# part of <command>.
# When invoking <command>, source and target filenames will be appended as
# additional arguments, and the standard output streams will be redirected
# into logfiles. The target filenames will point into the <sink> directory,
# and the log filenames will point into the <logs> directory.
# <sink> and <logs> will be created if they do not exist.
# Note that <command> will be invoked through `time` to measure runtimes.

set -e

BASE="$(pwd)"

if [ -z "$5" ]; then exit 1; fi
SOURCE="$1"
SINK="$2"
LOGS="$3"
OUTPUT_SUFFIX="$4"
shift 4

cd "$SOURCE"
mkdir -p "$BASE/$SINK"
mkdir -p "$BASE/$LOGS"

for f in network_*.csv; do (
  cd "$BASE"
  output_name="$(echo $f | sed 's/^network_\(.*\).csv/\1/')$OUTPUT_SUFFIX"
  set -x
  time $@ \
    "$SOURCE/$f" \
    "$SINK/$output_name" \
    >"$LOGS/$output_name.stdout.log" \
    2>"$LOGS/$output_name.stderr.log"
) done
