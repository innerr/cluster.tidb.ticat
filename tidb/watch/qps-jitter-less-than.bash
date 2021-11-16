set -euo pipefail

. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

session="${1}"
env_file="${session}/env"
env=`cat "${env_file}"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
shift

duration="${1}"
threshold="${2}"

url=http://`must_prometheus_addr "${name}"`

function past_n_seconds_qps_jitter()
{
    local n="${1}"
    local now=`timestamp`
    local begin=$((${now} - ${n}))000
    local end="${now}"000
    
    local qps_jt=(`metrics_jitter 'sum(rate(tidb_executor_statement_total{}[1m]))'`)
    if [[ "${qps_jt[0]}" == 'NaN' ]]; then
        qps_jt=('0' '0' '0')
    fi
    echo "${qps_jt}"
}

begin=`timestamp`

# Make sure we can observe the jitter
sleep $((${duration} / 2))

while [[ true ]]; do
    qps_jt=(`past_n_seconds_qps_jitter ${duration}`)
    echo "qps jt is ${qps_jt}"
    if [[ "${qps_jt[0]}" < "${threshold}" ]]; then
        break
    fi
    sleep 3
done

end=$((`timestamp` - ${duration}))
if [[ "${end}" < "${begin}" ]]; then
    end=${begin}
fi

echo "tidb.watch.no-qps-jitter.begin=${begin}" >> "${session}/env"
echo "tidb.watch.no-qps-jitter.end=${end}" >> "${session}/env"
