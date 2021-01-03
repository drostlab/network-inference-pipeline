#!/bin/sh

set -e

if [ -z "$2" ]; then exit 1; fi
SOURCE="$(pwd)/$1"
SINK="$(pwd)/$2"

cd "$SOURCE"
mkdir -p "$SINK"

for f in counts_*.csv; do
  for g in genes_*.csv; do
    result_file="counts_$( \
      echo $f | sed 's/^counts_\(.*\).csv/\1/' \
    )_$( \
      echo $g | sed 's/^genes_\(.*\).csv/\1/' \
    ).csv"
    xsv join gene $f gene $g | xsv 'select' '!gene[1]' >"$SINK/$result_file"
  done
done
