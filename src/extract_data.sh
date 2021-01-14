#!/bin/sh

set -e

if [ -z "$3" ]; then exit 1; fi
SOURCE="$(pwd)/$1"
SOURCE_SHA256="17bbc2d8c6da21bf3656f00c7ace353fa76e6ae83a91f101babaceb7cc821607"
SOURCE_SELECTOR="$2"
SINK="$(pwd)/$3"

mkdir -p "$SINK"
echo "$SOURCE_SHA256  $SOURCE" | sha256sum -c
unzip -j "$SOURCE" "$SOURCE_SELECTOR" -d "$SINK"
