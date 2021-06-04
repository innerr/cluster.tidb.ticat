set -uo pipefail

env=`cat "${1}/env"`
here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../utils/base.bash" "${env}"

name=`must_env_val "${env}" 'tidb.cluster'`

tiup cluster display "${name}" 1>/dev/null 2>&1
if [ "${?}" == 0 ]; then
	echo "[:)] cluster '${name}' verify succeeded"
else
	echo "[:(] cluster '${name}' verify failed" >&2
	exit 1
fi
