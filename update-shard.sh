#!/bin/bash
# This script updates a shard by:
# Looking for items that have been uploaded since the shard was created
# Looking for new files added to existing items
# Looking for files which have been modified (the hash has changed)
# Looking for files which have been removed from their item
# Looking for items which have gone dark since the shard was created

# It does not yet:
# Move items to a different shard if they are moved to a completely different collection

# Usage:
# ./update-shard.sh [OPTION] SHARD
#	-r NAME
#		record all output from all calls to the 'ia' tool, for later
#		use in test mode.
#	-t NAME
#		operate in test mode, reading the recorded output from the
#		'ia' tool rather than calling it.
#
#	SHARD is the name of a shard, and the script assumes that you
#	have a clone of the shard in the current directory. Note that
#	this script also assumes that there is a shardmeta branch
#	containing a get_all_items.sh script that can return a list of
#	items that ought to be in the shard; not all shards have this
#	yet so you might need to create one.

set -e

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

shard=$1
scriptdir="$(readlink --canonicalize-existing "$(dirname "${0}")")"

function gitannex {
	git-annex --quiet "$@"
}

IA=/usr/local/bin/ia
function ia {
	mock "${IA}" ia "${@}"
}

function mock {
	local prog="${1}"
	shift
	local path="${scriptdir}/test/mocks/${mockupname}/$(join "/" "${@}")"
	shift
	if [[ -f "${path}" ]] || [[ ! -z "${testmode}" ]]; then
		cat "${path}"
	elif [[ ! -z "${recordmode}" ]]; then
		mkdir -p "$(dirname "${path}")"
		"${prog}" "$@" | tee "${path}"
	else
		"${prog}" "$@"
	fi
}

function join {
	local IFS="${1}"
	shift
	echo "${*}"
}

# applypairs is just a pseudo-xargs that doesn't split up pairs of arguments
function applypairs {
	declare -n arr="${1}"
	declare -n length="${1}_len"
	local cmd="${2}"
	arr+=("${3}")
	arr+=("${4}")
	length=$((${length} + ${#3} + ${#4}))
	if [[ ${length} -gt $((100*1024)) ]]; then
		gitannex "${cmd}" --force "${arr[@]}"
		arr=()
		length=0
	fi
}

function pairfinish {
	declare -n arr="${1}"
	declare -n length="${1}_len"
	local cmd="${2}"
	shift 2
	local args="${@}"
	if [[ ${length} -gt $((0)) ]]; then
		gitannex "${cmd}" --force ${args} "${arr[@]}"
		arr=()
		length=0
	fi
}

# applypipe saves the args to a file and then pipes it to the command to finish
function applypipe {
	declare -n file="${1}"
	local cmd="${2}"
	echo "${3} ${4}" >> "${file}"
}
function pipefinish {
	declare -n file="${1}"
	local cmd="${2}"
	shift 2
	local args="${@}"
	cat "${file}" | pvn "git annex ${cmd}" | gitannex "${cmd}" --force ${args}
	rm "${file}"
}

FROMKEY="$(mktemp --suff=.fromkey)"
function fromkey {
	applypipe FROMKEY fromkey "$1" "$2"
}
function fromkey-finish {
	pipefinish FROMKEY fromkey
}

REKEY="$(mktemp --suff=.rekey)"
function rekey {
	applypipe REKEY rekey "$1" "$2"
}
function rekey-finish {
	pipefinish REKEY rekey --batch
}

REGISTERURL="$(mktemp --suff=.registerurl)"
function registerurl {
	applypipe REGISTERURL registerurl "$1" "$2"
}
function registerurl-finish {
	pipefinish REGISTERURL registerurl
}

RMURL="$(mktemp --suff=.rmurl)"
function rmurl {
	applypipe RMURL rmurl "$1" "$2"
}
function rmurl-finish {
	pipefinish RMURL rmurl --batch
}

function collectionFromItem {
	ls -d */"${1}" 2>&- | xargs -L1 dirname 2>&- | head -n 1
}

function mineia {
	while read i; do
		ia metadata "${i}"
	done
}

function parsejson {
	jq --raw-output -f "${scriptdir}/get_item_updates.jq"
}

function getitems {
	mock "${1}/get_all_items.sh" get_all_items.sh
	find -mindepth 2 -type d -not -path "*/.git/*" | xargs -L1 basename 2>&-
}

function getfiles {
	cat "${tmpitems}" | mineia | parsejson
}

function pad {
	printf "%${1}s" "${2}"
}

function pvn {
	local msg="$(pad 25 "${1}")"
	pv -N "${msg}" -cltab
}

function findfiles {
	cd "${1}"; find "${2}" -mindepth 1 | sort
}

function listfiles {
	declare -n filelist="${1}"
	local IFS=$'\n'
	echo "${filelist[*]}" | sort
}

function archiveurl {
	echo "https://archive.org/download/$(urlencode -m "${1}")"
}

function addrmfiles {
	local savedcollection=
	local saveditem=
	local saveditem_files=()

	while read update collection item key filename; do
		# The $collection here is simply the first collection
		# in the list of collections that this item belongs
		# to. We want to put the item in a stable location
		# even if that list changes, so we first look to see
		# what directory we put it in last time, if any.
		local currentcollection="$(collectionFromItem "${item}")"
		if [[ -z "${currentcollection}" ]]; then
			currentcollection="${collection}"
		fi
		local url="$(archiveurl "${filename}")"
		local path="${currentcollection}/${filename}"
		if [[ "dark" = "${update:-x}" ]]; then
			# The metadata for dark items doesn't include
			# a file list, so we have to enumerate the
			# files on disk directly.
			(cd "${currentcollection}";
			 for file in ${item}/*; do
				 rmurl "${file}" "$(archiveurl "${file}")"
			 done)
		else
			# Calculates the key from the url exactly as
			# git-annex will do it.
			if [[ "${key}" = "URL--" ]]; then
				if [[ "${#url}" -gt 64 ]]; then
					key="URL--${url:0:31}-$(echo "${url}" | md5sum - | cut -d ' ' -f 1)"
				else
					key="URL--${url}"
				fi
			fi
			if [[ ! -h "${path}" ]]; then
				fromkey "${key}" "${path}"
				registerurl "${key}" "${url}"
			elif [[ "x$(git annex lookupkey "${path}")" != "x${key}" ]]; then
				rekey "${path}" "${key}"
			fi
		fi
		# Once we've been through all the current files in the
		# item, we need to enumerate the local files for the
		# item and see if we have any that aren't in the
		# metadata; this will indicate that they were at some
		# point removed from the item. Of course this would
		# be simpler if we still had everything grouped by
		# item.
		if [[ -z "${saveditem}" ]]; then
			savedcollection="${currentcollection}"
			saveditem="${item}"
		fi
		if [[ "x${item}" = "x${saveditem}" ]]; then
			saveditem_files+=("${filename}")
		else
			if [[ -d "${savedcollection}/${saveditem}" ]]; then
				comm -23 <(findfiles "${savedcollection}" "${saveditem}") <(listfiles saveditem_files) | while read file; do
					rmurl "${savedcollection}/${file}" "$(archiveurl "${file}")"
				done
			fi
			savedcollection="${currentcollection}"
			saveditem="${item}"
			saveditem_files+=("${filename}")
		fi
	done

	if [[ ! -z "${saveditem}" ]] && [[ -d "${savedcollection}/${saveditem}" ]]; then
		comm -23 <(findfiles "${savedcollection}" "${saveditem}") <(listfiles saveditem_files) | while read file; do
			rmurl "${savedcollection}/${file}" "$(archiveurl "${file}")"
		done
	fi
}

if [[ ! -d "${shard}" ]]; then
	echo "No shard named '${shard}' exists"
	exit 1
fi

pushd "${shard}"

commit_msg="updating ${shard}"
if ! git branch -v | grep -q master; then
	commit_msg="creating ${shard}"
	git checkout --orphan master
	git rm -rf . 2>&- || true
elif [[ "x$(git rev-parse --abbrev-ref HEAD)" != "xmaster" ]]; then
	git checkout master
fi

tmpdir="$(mktemp -d)"
git clone --shared --branch shardmeta -- . "${tmpdir}"

tmpitems="$(mktemp)"
getitems "${tmpdir}" | pvn "search for items" | sort -u > "${tmpitems}"

IFS=$'\t'
getfiles | pvn "enumerate files" | addrmfiles

fromkey-finish
rekey-finish
registerurl-finish
rmurl-finish

rm -rf -- "${tmpdir}" "${tmpitems}"

git annex merge
git commit --quiet -a -m "${commit_msg}"

popd
