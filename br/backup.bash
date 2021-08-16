set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env=`cat "${1}/env"`

name=`must_env_val "${env}" 'br.cluster'`
dir=`must_env_val "${env}" 'br.backup-dir'`

pd=`must_cluster_pd "${name}"`

br backup full --pd "${pd}" -s "${dir}" --check-requirements=false
