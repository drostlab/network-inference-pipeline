#!/bin/sh

set -e

if [ -z "$2" ]; then exit 1; fi
SOURCE="$(pwd)/$1"
SINK="$(pwd)/$2"

cd "$SOURCE"
mkdir -p "$SINK"

# Rename the first cell to `"gene"` and normalize inputs
cat counts_raw.csv | sed 's/^""/"gene"/' | xsv input >"$SINK/counts_raw.csv"

for f in genes_*.csv; do
  # Insert a (single-column) header and normalize inputs
  echo '"gene"' | cat - $f | xsv input >"$SINK/$f"
done

xsv select id_df,time metadata.csv | sed 's/^id_df,time/sample,group/' >"$SINK/samples.csv"
