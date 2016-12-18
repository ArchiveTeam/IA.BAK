#!/bin/bash

set -e

scriptdir="$(readlink --canonicalize-existing "$(dirname "${0}")")"
sharddir="$(mktemp --directory --suff .testshard)"

pass=0
fail=0
total=0

function exists
{
	total=$((total+1))
	filename="${1}"
	if [[ -h "${filename}" ]] && git-annex whereis "${filename}" &>-; then
		echo -n .
		pass=$((pass+1))
	else
		echo -n x
		fail=$((fail+1))
	fi
}

function doesntexist
{
	total=$((total+1))
	filename="${1}"
	if [[ ! -h "${filename}" ]]; then
		echo -n .
		pass=$((pass+1))
	else
		echo -n x
		fail=$((fail+1))
	fi
}

function exists_nourl
{
	total=$((total+1))
	filename="${1}"
	if [[ -h "${filename}" ]] && ! git-annex whereis "${filename}" &>-; then
		echo -n .
		pass=$((pass+1))
	else
		echo -n x
		fail=$((fail+1))
	fi
}

function keyis {
	total=$((total+1))
	filename="${1}"
	key="${2}"
	if [[ -h "${filename}" ]] && [[ "x$(git-annex lookupkey "${filename}")" = "x${key}" ]]; then
		echo -n .
		pass=$((pass+1))
	else
		echo -n x
		fail=$((fail+1))
	fi
}

pushd "$(dirname "${sharddir}")" &>-
echo "create shard"
"${scriptdir}/../make-shard.sh" -t "basic-testcase-first" "${sharddir}" softwarelibrary_win3_showcase &>-
pushd "${sharddir}" &>-
exists "softwarelibrary_win3_showcase/win311_masque_chessnet/CHESSNET.ZIP"
keyis "softwarelibrary_win3_showcase/win311_masque_chessnet/win311_masque_chessnet_meta.sqlite" "MD5-s12288--511557d1a393c0079dd782f2abdc8553"
exists "softwarelibrary_win3_showcase/win32c/win32c.zip"
doesntexist "softwarelibrary_win3_showcase/win3_MidMM211/MidMM211.zip"
echo
popd &>-

echo "update shard"
"${scriptdir}/../update-shard.sh" -t "basic-testcase-second" "${sharddir}" &>-
pushd "${sharddir}" &>-
exists_nourl "softwarelibrary_win3_showcase/win311_masque_chessnet/CHESSNET.ZIP"
keyis "softwarelibrary_win3_showcase/win311_masque_chessnet/win311_masque_chessnet_meta.sqlite" "MD5-s12288--000000000123456789abcdef01234567"
exists_nourl "softwarelibrary_win3_showcase/win32c/win32c.zip"
exists "softwarelibrary_win3_showcase/win3_MidMM211/MidMM211.zip"
echo
popd &>-

echo "${pass} of ${total} tests passed"
if [[ "${fail}" -gt 0 ]]; then
	echo "You may wish to examine ${sharddir} to see what went wrong"
	exit 1;
fi

rm -rf "${sharddir}"
