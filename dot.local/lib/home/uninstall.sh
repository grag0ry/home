#!/bin/bash

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" || exit 1

echo "Waiting 5 seconds before starting..."
echo "(Control-C to abort)"
echo -n "Uninstalling in:"
for ((i=5; i>0; i--)); do
    echo -n " $i"
    sleep 1
done
echo

for s in uninstall/*-uninstall.sh; do
    printf "%s\n" "$s"
    "$s"
done
