set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`
meta=`must_cluster_exists "${name}"`

tiup cluster clean --all "${name}"${confirm}
