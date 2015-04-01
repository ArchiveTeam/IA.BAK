#!/bin/sh
# Run as root by pushme.cgi.
base="$(dirname $0)"
(cd "$base/pubkeys" && git pull)
"$base/update-authorized_keys" SHARD1
