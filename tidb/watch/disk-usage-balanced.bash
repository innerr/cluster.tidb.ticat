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

while [[ true ]]; do
    region_scores=`tiup ctl:${version} pd -u "${pd_leader_id}" store --jq ".stores[].status.region_score"`
    region_scores=`echo "${region_scores}" | tr '\n' ','`

    percentage=$(
python - <<EOF
region_scores = [${region_scores}]
m = sum(region_scores) / len(region_scores)
largest = max(region_scores)
smallest = min(region_scores)
print((largest - smallest) / m)
EOF
)

    # Can we find a better way?
    if [[ $percentage < 0.05 ]]; then
        break;
    fi
done
