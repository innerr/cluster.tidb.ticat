set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
shift

pd_leader_id=`must_pd_leader_id "${name}"`
version=`env_val "${env}" 'tidb.version'`
if [ -z "${version}" ]; then
    version=`must_cluster_version "${name}"`
fi

# FIXME find a better way?
# the default value of tikv down peer's heartbeat duration is 10m
sleep 600   

while [[ true ]]; do
    count=`tiup ctl:${version} pd -u "${pd_leader_id}" region --jq '[.regions[] | select((.down_peers|length)>0)] | length'`
    if [[ "${count}" == "0" ]]; then
        break
    fi
done
