#!/bin/sh
# Run as root by pushme.cgi.
cd "$(dirname $0)"/pubkeys
git pull
