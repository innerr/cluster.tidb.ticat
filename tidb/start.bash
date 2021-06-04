set -euo pipefail

env=`cat "${1}/env"`
here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../utils/base.bash" "${env}"

name=`must_env_val "${env}" 'tidb.cluster'`
tiup cluster start "${name}"
