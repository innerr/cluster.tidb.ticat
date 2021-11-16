set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
warmup="${3}"
shift 3

pd_leader_id=`must_pd_leader_id "${name}"`
version=`env_val "${env}" 'tidb.version'`
if [ -z "${version}" ]; then
    version=`must_cluster_version "${name}"`
fi

begin=`timestamp`

sleep "${warmup}"

while [[ true ]]; do
    count=`tiup ctl:${version} pd -u "${pd_leader_id}" region --jq '[.regions[] | select((.down_peers|length)>0)] | length'`
    if [[ "${count}" == "0" ]]; then
        break
    fi
done

end=`timestamp`

echo "tidb.watch.no-down-peers.begin=${begin}" >> "${session}/env"
echo "tidb.watch.no-down-peers.end=${end}" >> "${session}/env"
