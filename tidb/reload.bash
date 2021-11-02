set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`
shift

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`

shift 2
force=`enable_opt "${1}" '--force'`
skip_restart=`enable_opt "${2}" '--skip-restart'`
roles=''

# remove roles' whitespace
if [ ! -z "${3// }" ]; then
	roles=" --role ${3// }"
fi

tiup cluster reload "${name}" ${force}${skip_restart}${roles}${confirm}
