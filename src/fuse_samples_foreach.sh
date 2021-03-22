#!/bin/sh

set -e

BASE="$(pwd)"

if [ -z "$3" ]; then exit 1; fi
SOURCE="$1"
SAMPLES="$2"
SINK="$3"
shift 3

cd "$SOURCE"
mkdir -p "$BASE/$SINK"

for f in counts_*.csv; do (
  cd "$BASE"
  set -x
  Rscript src/fuse_samples.R "$SOURCE/$f" "$SAMPLES" "$SINK/$f"
) done

set -x
cp genes_*.csv "$BASE/$SINK"
