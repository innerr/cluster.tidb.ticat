set -uo pipefail

env=`cat "${1}/env"`

name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

tiup cluster display "${name}" 1>/dev/null 2>&1
if [ "${?}" == 0 ]; then
	echo "[:)] cluster '${name}' verify succeeded"
else
	echo "[:(] cluster '${name}' verify failed" >&2
	exit 1
fi
