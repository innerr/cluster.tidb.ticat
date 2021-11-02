set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`
shift

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`

shift 2
force=''
skip_restart=''
roles=''

if [ `to_true "${1}"` == "true" ]; then
    force=' --force'
fi

if [ `to_true "${2}"` == "true" ]; then
    skip_restart=' --skip-restart'
fi

if [ ! -z "${3}" ]; then
    roles=" --role ${3}"
fi

tiup cluster reload ${name}${force}${skip_restart}${roles}${confirm}
