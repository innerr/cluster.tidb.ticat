set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

env_file="${1}/env"
env=`cat "${env_file}"`
shift

url=`must_env_val "${env}" 'metrics.prometheus.url'`
begin=`must_env_val "${env}" 'metrics.begin'`
end=`must_env_val "${env}" 'metrics.end'`

lat95_jt=(`metrics_jitter 'histogram_quantile(0.95, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
lat99_jt=(`metrics_jitter 'histogram_quantile(0.99, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
lat999_jt=(`metrics_jitter 'histogram_quantile(0.999, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
qps_jt=(`metrics_jitter 'sum(rate(tidb_executor_statement_total{}[1m])) by (type)'`)

if [ "${qps_jt[0]}" == 'NaN' ]
then
    qps_jt=('0' '0' '0')
fi

tidb_cpu_agg=(`metrics_aggregate 'irate(process_cpu_seconds_total{job="tidb"}[30s])'`)
tidb_mem_agg=(`metrics_aggregate 'process_resident_memory_bytes{job="tidb"}'`)
tidb_max_procs=(`metrics_aggregate 'tidb_server_maxprocs{job="tidb"}'`)

echo "metrics.tidb.cpu.usage.avg=${tidb_cpu_agg[0]}" >> "${env_file}"
echo "metrics.tidb.cpu.usage.max=${tidb_cpu_agg[1]}" >> "${env_file}"
echo "metrics.tidb.max.procs=${tidb_max_procs[0]}" >> "${env_file}"

echo "metrics.tidb.mem.usage.avg=${tidb_mem_agg[0]}" >> "${env_file}"
echo "metrics.tidb.mem.usage.max=${tidb_mem_agg[1]}" >> "${env_file}"

echo "metrics.lat95.jt.sd=${lat95_jt[0]}" >> "${env_file}"
echo "metrics.lat95.jt.pos.max=${lat95_jt[1]}" >> "${env_file}"

echo "metrics.lat99.jt.sd=${lat99_jt[0]}" >> "${env_file}"
echo "metrics.lat99.jt.pos.max=${lat99_jt[1]}" >> "${env_file}"

echo "metrics.lat999.jt.sd=${lat999_jt[0]}" >> "${env_file}"
echo "metrics.lat999.jt.neg.max=${lat999_jt[2]}" >> "${env_file}"

echo "metrics.qps.jt.sd=${qps_jt[0]}" >> "${env_file}"
echo "metrics.qps.jt.neg.max=${qps_jt[2]}" >> "${env_file}"
