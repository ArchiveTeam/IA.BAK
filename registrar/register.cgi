#!/bin/sh
set -e
echo "Content-Type: text/plain"
echo ""
sudo -u registrar /home/registrar/IA.BAK/registrar/register.pl
