if ! FLOCK=$(which flock); then
	FLOCK="$(pwd)/flock.pl"
fi

FLOCK_SH="${FLOCK} -s"
FLOCK_EX="${FLOCK} -x"

GIT="${FLOCK_SH} $(pwd)/.iabak-install-git-annex git"
GITANNEX="${GIT} annex"
