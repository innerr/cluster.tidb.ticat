set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`

name=`must_env_val "${env}" 'tidb.cluster'`
yaml=`must_env_val "${env}" 'tidb.tiup.yaml'`

tiup cluster scale-out -y "${name}" "${yaml}"
