set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
shift

cluster_info=`tiup cluster display ${name} -R tikv --json`
num_tikvs=`echo "${cluster_info}" | jq ".instances | length"`
selected_tikv_index=$(($RANDOM % ${num_tikvs}))
tikv_node_id=`echo "${cluster_info}" | jq --argjson v "${selected_tikv_index}" '.instances[$v].host'`

tiup cluster stop ${name} -R tikv -N "${tikv_node_id}"
