#!/bin/sh

set -e

BASE="$(pwd)"

if [ -z "$2" ]; then exit 1; fi
SOURCE="$1"
SINK="$2"
shift 2

cd "$SOURCE"
mkdir -p "$BASE/$SINK"

for f in counts_*.csv; do (
  cd "$BASE"
  set -x
  Rscript src/fuse_samples.R "$SOURCE/$f" "$SOURCE/samples.csv" "$SINK/$f"
) done

set -x
cp genes_*.csv "$BASE/$SINK"
