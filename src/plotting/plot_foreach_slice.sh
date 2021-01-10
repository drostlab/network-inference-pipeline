#!/bin/sh

# Usage:
#  plot_foreach_slice.sh <source> <sink> <logs> <command ...>
#
# This script will iterate all files named `network_raw_*.csv` in the <source>
# directory, replace `raw` by `VARIANT` and call back <command> for each one
# of these filename templates. All arguments to this script trailing the first
# three (<source>, <sink> and <logs>) will be considered  part of <command>.
# When invoking <command>, source and target filenames will be appended as
# additional arguments, and the standard output streams will be redirected
# into logfiles. The target filenames will point into the <sink> directory,
# and the log filenames will point into the <logs> directory.
# <sink> and <logs> will be created if they do not exist.
# Note that <command> will be invoked through `time` to measure runtimes.

set -e

BASE="$(pwd)"

if [ -z "$4" ]; then exit 1; fi
SOURCE="$1"
SINK="$2"
LOGS="$3"
shift 3

cd "$SOURCE"
mkdir -p "$BASE/$SINK"
mkdir -p "$BASE/$LOGS"

for f in network_raw_*.csv; do (
  cd $BASE
  input_name="$(echo $f | sed 's/^network_raw_\(.*\)/network_VARIANT_\1/')"
  output_name="$(echo $f | sed 's/^network_\(.*\).csv/\1/')"
  set -x
  time $@ \
    "$SOURCE/$input_name" \
    "$SINK/$output_name" \
    >"$LOGS/slices_$output_name.stdout.log" \
    2>"$LOGS/slices_$output_name.stderr.log"
) done
