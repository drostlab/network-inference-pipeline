#!/bin/sh

set -e

BASE="$(pwd)"

if [ -z "$4" ]; then exit 1; fi
SOURCE="$1"
COUNTS="$2"
SINK="$3"
LOGS="$4"

mkdir -p "$BASE/$SINK"
mkdir -p "$BASE/$LOGS"

set -x
Rscript src/denoise.R "$SOURCE/$COUNTS" "$SINK" >"$BASE/$LOGS/denoise.stdout" 2>"$BASE/$LOGS/denoise.stderr"
cp "$SOURCE"/genes_*.csv "$BASE/$SINK"
