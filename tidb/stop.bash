set -euo pipefail

env=`cat "${1}/env"`
here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../utils/base.bash" "${env}"

confirm=`confirm_str "${env}"`
name=`must_env_val "${env}" 'tidb.cluster'`
tiup cluster stop "${name}"${confirm}
