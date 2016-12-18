#!/bin/bash
# Usage:
# ./make-shard.sh [OPTION] <shard> <collection> [<collection> ...]
#	-r NAME
#		record all output from all calls to the 'ia' tool, for later
#		use in test mode.
#	-t NAME
#		operate in test mode, reading the recorded output from the
#		'ia' tool rather than calling it.
#
#	<shard> is the name of a new shard to create
#	<collection> is the name of any collection of items on IA
#
# 	This script creates a new shard containing all items which appear in
# 	any of the named collections. To avoid overloading the resulting git
# 	repository, or the hard drives of users who may wish do download the
# 	complete shard, please avoid creating shards with more than ~100,000
# 	files or which use more than ~4TB of disk space.

testmode=
recordmode=
mockupname=
while getopts ":t:r:" opt; do
	case "${opt}" in
		t)
			testmode=1
			mockupname="${OPTARG}"
			;;
		r)
			recordmode=1
			mockupname="${OPTARG}"
			;;
		\?)
			echo "unknown option -${OPTARG}"
			exit 128
			;;
		:)
			echo "option -${OPTARG} requires an argument"
			exit 128
			;;
	esac
done
if [[ ! -z "${testmode}" ]] && [[ ! -z "${recordmode}" ]]; then
	echo "cannot enable both test mode and record mode at the same time"
	exit 129
fi
shift $((OPTIND-1))

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
if [[ -d "${shard}/.git" ]]; then
	echo "${shard} already exists"
	exit 1
fi
if [[ -z "${criteria}" ]]; then
	echo "you must specify at least one collection to put in the shard"
	exit 1
fi
scriptdir="$(readlink --canonicalize-existing "$(dirname "${0}")")"

mkdir -p "${shard}"
pushd "${shard}"
git init
git annex init
git checkout --orphan shardmeta
echo "*~" > .gitignore
echo "\#*" >> .gitignore
cat <<-EOF > get_all_items.sh
	#!/bin/sh
	ia search --itemlist "${criteria}"
EOF
chmod u+x get_all_items.sh
git add .gitignore get_all_items.sh
git commit -m "creating shard metadata branch"
git checkout --orphan master
git rm -rf .
popd

args=
if [[ ! -z "${testmode}" ]]; then
	args="-t ${mockupname}"
elif [[ ! -z "${recordmode}" ]]; then
	args="-r ${mockupname}"
fi
"${scriptdir}/update-shard.sh" ${args} "${shard}"
