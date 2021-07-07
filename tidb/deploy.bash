set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`

confirm=`confirm_str "${env}"`
yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`
name=`must_env_val "${env}" 'tidb.cluster'`
ver=`must_env_val "${env}" 'tidb.version'`

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}
