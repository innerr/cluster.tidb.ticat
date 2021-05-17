set -uo pipefail

env_file="${1}/env"
shift
env=`cat ${env_file}`

name=`echo "${env}" | grep '^tidb.cluster' | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

set -e
tiup cluster stop "${name}"
