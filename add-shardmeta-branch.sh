#!/bin/bash
# Usage:
# ./add-shardmeta-branch.sh [OPTION] <shard> <collection> [<collection> ...]
#	<shard> is the name of a new shard to create
#	<collection> is the name of any collection of items on IA
#
# 	This script updates an existing shard so that it has a
# 	shardmeta branch with a get_all_items.sh script.

set -e

shard=${1}
shift
criteria=
for c in "$@"; do
	if [[ ! -z "${criteria}" ]]; then
		criteria+=" OR "
	fi
	criteria+="collection:${c}"
done
if [[ ! -d "${shard}/.git" ]]; then
	echo "${shard} doesn't exist"
	exit 1
fi
if [[ -z "${criteria}" ]]; then
	echo "you must specify at least one collection to put in the shard"
	exit 1
fi
scriptdir="$(readlink --canonicalize-existing "$(dirname "${0}")")"

pushd "${shard}"

if git branch | grep -q shardmeta; then
	echo "${shard} already has a shardmeta branch; skipping it"
	exit 0
fi

git checkout --orphan shardmeta
git rm -rf . &>- || true
echo "*~" > .gitignore
echo "\#*" >> .gitignore
cat <<-EOF > get_all_items.sh
	#!/bin/sh
	ia search --itemlist "${criteria}"
EOF
chmod u+x get_all_items.sh
git add .gitignore get_all_items.sh
git commit -m "creating shard metadata branch"
git checkout master
popd
