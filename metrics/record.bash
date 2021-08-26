set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"

session="${1}"
env=`cat "${session}/env"`
shift

## Args handling
#
workload=`must_env_val "${env}" 'bench.workload'`
bench_begin=`env_val "${env}" 'bench.begin'`
run_begin=`must_env_val "${env}" 'bench.run.begin'`
run_end=`must_env_val "${env}" 'bench.run.end'`

metrics_begin=`must_env_val "${env}" 'metrics.begin'`
metrics_end=`must_env_val "${env}" 'metrics.end'`

tidb_cpu_usage_avg=`must_env_val "${env}" 'metrics.tidb.cpu.usage.avg'`
tidb_cpu_usage_max=`must_env_val "${env}" 'metrics.tidb.cpu.usage.max'`
tidb_max_procs=`must_env_val "${env}" 'metrics.tidb.max.procs'`
tidb_mem_usage_avg=`must_env_val "${env}" 'metrics.tidb.mem.usage.avg'`
tidb_mem_usage_max=`must_env_val "${env}" 'metrics.tidb.mem.usage.max'`
lat95_jt_sd=`must_env_val "${env}" 'metrics.lat95.jt.sd'`
lat95_jt_pos_max=`must_env_val "${env}" 'metrics.lat95.jt.pos.max'`
lat99_jt_sd=`must_env_val "${env}" 'metrics.lat99.jt.sd'`
lat99_jt_pos_max=`must_env_val "${env}" 'metrics.lat99.jt.pos.max'`
lat999_jt_sd=`must_env_val "${env}" 'metrics.lat999.jt.sd'`
lat999_jt_neg_max=`must_env_val "${env}" 'metrics.lat999.jt.neg.max'`
qps_jt_sd=`must_env_val "${env}" 'metrics.qps.jt.sd'`
qps_jt_neg_max=`must_env_val "${env}" 'metrics.qps.jt.neg.max'`

if [ -z "${bench_begin}" ]; then
	bench_begin='0'
fi

## Write the text record, in case no meta db
#
echo -e "workload=${workload},run_begin=${run_begin},run_end=${run_end}" >> "${session}/metrics"

host=`env_val "${env}" 'bench.meta.host'`
if [ -z "${host}" ]; then
	echo "[:-] no bench.meta.host in env, skipped" >&2
	exit
fi

## Write the record tables if has meta db
#
port=`must_env_val "${env}" 'bench.meta.port'`
db=`must_env_val "${env}" 'bench.meta.db-name'`

function my_exe()
{
	local query="${1}"
	mysql -h "${host}" -P "${port}" -u root --database="${db}" -e "${query}"
}

mysql -h "${host}" -P "${port}" -u root -e "CREATE DATABASE IF NOT EXISTS ${db}"

function write_record()
{
	local table="${1}"

	my_exe "CREATE TABLE IF NOT EXISTS ${table} (   \
        workload VARCHAR(64),                       \
        bench_begin TIMESTAMP,                      \
        run_begin TIMESTAMP,                        \
        \`tidb_cpu%_avg\` DECIMAL(12,2),            \
        \`tidb_cpu%_max\` DECIMAL(12,2),            \
        tidb_procs INT(3),                          \
        tidb_mem_avg_gb DECIMAL(12,3),              \
        tidb_mem_max_gb DECIMAL(12,3),              \
        lat95_jt_sd DECIMAL(12,2),                  \
        lat95_jt_pos_max DECIMAL(12,2),             \
        lat99_jt_sd DECIMAL(12,2),                  \
        lat99_jt_pos_max DECIMAL(12,2),             \
        lat999_jt_sd DECIMAL(12,2),                 \
        lat999_jt_neg_max DECIMAL(12,2),            \
        qps_jt_sd DECIMAL(12,2),                    \
        qps_jt_neg_max DECIMAL(12,2),               \
		PRIMARY KEY(                                \
			workload,                               \
			bench_begin,                            \
			run_begin                               \
		)                                           \
	)                                               \
	"

	my_exe "INSERT INTO ${table} VALUES(            \
		\"${workload}\",                            \
		FROM_UNIXTIME(${bench_begin}),              \
		FROM_UNIXTIME(${metrics_begin}/1000),       \
        ${tidb_cpu_usage_avg},                      \
        ${tidb_cpu_usage_max},                      \
        ${tidb_max_procs},                          \
        ${tidb_mem_usage_avg}/1000000000,           \
        ${tidb_mem_usage_max}/1000000000,           \
        ${lat95_jt_sd},                             \
        ${lat95_jt_pos_max},                        \
        ${lat99_jt_sd},                             \
        ${lat99_jt_pos_max},                        \
        ${lat999_jt_sd},                            \
        ${lat999_jt_neg_max},                       \
        ${qps_jt_sd},                               \
        ${qps_jt_neg_max}                           \
	)                                               \
	"
}

write_record 'metrics'
