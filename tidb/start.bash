set -euo pipefail

env_file="${1}/env"
shift
env=`cat "${env_file}"`

name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

tiup cluster start "${name}"
