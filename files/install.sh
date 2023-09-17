#!/bin/sh

if [ "$1" != "fedora" -a "$1" != "debian" ]; then
    echo "Usage: $0 [fedora|debian]" 1>&2
    exit 2
fi

(echo "set -e"; sed -e 's/^/install -m 644 -b -C -D /' $1.manifest) | sh
