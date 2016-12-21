#!/bin/sh
# Run as root by pushme.cgi.
base=/usr/local/IA.BAK
cd "$base/pubkeys"
for remote in $(git remote); do
	git pull "$remote" master;
done
for SHARD in SHARD*; do
	"$base/update-authorized_keys" "$SHARD"
done
