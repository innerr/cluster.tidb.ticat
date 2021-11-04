set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
host=`must_env_val "${env}" 'tidb.node.host'`
port=`must_env_val "${env}" 'tidb.node.port'`
shift 3

address="${host}:${port}"
pd_leader_id=`must_pd_leader_id "${name}"`
version=`env_val "${env}" 'tidb.version'`
if [ -z "${version}" ]; then
    version=`must_cluster_version "${name}"`
fi

store_id=`must_store_id "${pd_leader_id}" "${version}" "${address}"`

while true; do
    leader_count=`tiup ctl:${version} pd -u "${pd_leader_id}" \
        store ${store_id} --jq ".status.leader_count" 2>/dev/null`
    if [ "${leader_count}" == "0" ]; then
        break
    fi
    sleep 1
done
