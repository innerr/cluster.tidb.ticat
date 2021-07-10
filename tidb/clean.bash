set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`
exist=`cluster_exist "${name}"`
if [ "${exist}" == 'false' ]; then
	echo "[:-] cluster '${name}' not exist, skipped"
	exit
fi

tiup cluster clean --all "${name}"${confirm}
