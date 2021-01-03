#!/bin/sh

set -e

if [ -z "$3" ]; then exit 1; fi
ALGORITHM="$1"
SOURCE="$(pwd)/$2"
SINK="$(pwd)/$3"
SCRIPT="$(pwd)/src/NetworkInference.jl/infer_network.jl"

set -x

cd "$SOURCE"
mkdir -p "$SINK"

for f in counts_*.csv; do
  time julia $SCRIPT \
    $ALGORITHM \
    $f \
    "$SINK/network_$f" \
    >"$SINK/network_$f.stdout.log" \
    2>"$SINK/network_$f.stderr.log"
done
