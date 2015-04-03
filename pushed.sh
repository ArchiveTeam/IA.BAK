#!/bin/sh
# Run as root by pushme.cgi.
base=/usr/local/IA.BAK
cd "$base/pubkeys"
git pull
for SHARD in SHARD*; do
	"$base/update-authorized_keys" "$SHARD"
done
