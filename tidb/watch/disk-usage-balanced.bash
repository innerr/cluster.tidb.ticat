set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

session="${1}"
env=`cat "${session}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
shift

pd_leader_id=`must_pd_leader_id "${name}"`
version=`env_val "${env}" 'tidb.version'`
if [ -z "${version}" ]; then
    version=`must_cluster_version "${name}"`
fi

begin=`timestamp`

while [[ true ]]; do
    region_scores=`tiup ctl:${version} pd -u "${pd_leader_id}" store --jq ".stores[].status.region_score"`
    percentage=`echo "${region_scores}" | awk '
    {
        if (max == "" ) {
            max = $1
        }
        if (max < $1) {
            max = $1
        }
        total += $1;
        count += 1;
    }
    END {
        mean = total / count
        print (max - mean) / mean
    }
'`

    # Can we find a better way?
    if [[ $percentage < 0.05 ]]; then
        break;
    fi
done

end=`timestamp`

echo "tidb.watch.disk-usage-balanced.begin=${begin}" >> "${session}/env"
echo "tidb.watch.disk-usage-balanced.end=${end}" >> "${session}/env"