#!/bin/sh

set -e

if [ -z "$2" ]; then exit 1; fi
SOURCE="$(pwd)/$1"
SINK="$(pwd)/$2"

cd "$SOURCE"
mkdir -p "$SINK"

for f in counts_*.csv; do
  # Rename the first cell to `"gene"` and normalize inputs
  cat $f | sed 's/^""/"gene"/' | xsv input >"$SINK/$f"
done

for f in genes_*.csv; do
  # Insert a (single-column) header and normalize inputs
  echo '"gene"' | cat - $f | xsv input >"$SINK/$f"
done

xsv select id_df,time metadata.csv | sed 's/^id_df,time/sample,group/' >"$SINK/samples.csv"
