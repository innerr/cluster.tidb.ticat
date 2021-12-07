set -euo pipefail

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

session="${1}"
env_file="${session}/env"
env=`cat "${env_file}"`
shift

event_prefix="${1}"
name=`must_env_val "${env}" 'tidb.cluster'`
url=http://`must_prometheus_addr "${name}"`
begin=`must_env_val "${env}" "${event_prefix}.begin"`000
end=`must_env_val "${env}" "${event_prefix}.end"`000

lat95_jt=(`metrics_jitter 'histogram_quantile(0.95, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
lat99_jt=(`metrics_jitter 'histogram_quantile(0.99, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
lat999_jt=(`metrics_jitter 'histogram_quantile(0.999, sum(rate(tidb_server_handle_query_duration_seconds_bucket{}[1m])) by (le, instance))'`)
qps_jt=(`metrics_jitter 'sum(rate(tidb_executor_statement_total{}[1m])) by (type)'`)

if [ "${qps_jt[0]}" == 'NaN' ]
then
	qps_jt=('0' '0' '0')
fi

qps_jt_sd="${qps_jt[0]}"
qps_jt_neg_max="${qps_jt[2]}"
lat95_jt_sd="${lat95_jt[0]}"
lat95_jt_pos_max="${lat95_jt[1]}"
lat99_jt_sd="${lat99_jt[0]}"
lat99_jt_pos_max="${lat99_jt[1]}"
lat999_jt_sd="${lat999_jt[0]}"
lat999_jt_neg_max="${lat999_jt[2]}"

echo "${event_prefix}.jitter.qps.sd=${qps_jt_sd}" >> "${env_file}"
echo "${event_prefix}.jitter.qps.neg.max=${qps_jt_neg_max}" >> "${env_file}"
echo "${event_prefix}.jitter.lat95.sd=${lat95_jt_sd}" >> "${env_file}"
echo "${event_prefix}.jitter.lat95.pos.max=${lat95_jt_pos_max}" >> "${env_file}"
echo "${event_prefix}.jitter.lat99.sd=${lat99_jt_sd}" >> "${env_file}"
echo "${event_prefix}.jitter.lat99.pos.max=${lat99_jt_pos_max}" >> "${env_file}"
echo "${event_prefix}.jitter.lat999.sd=${lat999_jt_sd}" >> "${env_file}"
echo "${event_prefix}.jitter.lat999.neg.max=${lat999_jt_neg_max}" >> "${env_file}"

host=`env_val "${env}" 'bench.meta.host'`
if [ -z "${host}" ]; then
	echo "[:-] no bench.meta.host in env, skipped" >&2
	exit
fi

## Write the metrics tables if has meta db
#
port=`must_env_val "${env}" 'bench.meta.port'`
db=`must_env_val "${env}" 'bench.meta.db-name'`
user=`must_env_val "${env}" 'bench.meta.user'`

function my_exe()
{
	local query="${1}"
	mysql -h "${host}" -P "${port}" -u "${user}" --database="${db}" -e "${query}"
}

mysql -h "${host}" -P "${port}" -u "${user}" -e "CREATE DATABASE IF NOT EXISTS ${db}"

function write_record()
{
	local table="${1}"

	my_exe "CREATE TABLE IF NOT EXISTS ${table} (   \
		prefix VARCHAR(64),                         \
		begin TIMESTAMP,                            \
		end TIMESTAMP,                              \
		lat95_jt_sd DECIMAL(12,2),                  \
		lat95_jt_pos_max DECIMAL(12,2),             \
		lat99_jt_sd DECIMAL(12,2),                  \
		lat99_jt_pos_max DECIMAL(12,2),             \
		lat999_jt_sd DECIMAL(12,2),                 \
		lat999_jt_neg_max DECIMAL(12,2),            \
		qps_jt_sd DECIMAL(12,2),                    \
		qps_jt_neg_max DECIMAL(12,2),               \
		PRIMARY KEY(                                \
			prefix,                                 \
			begin                                   \
		)                                           \
	)                                               \
	"

	my_exe "INSERT INTO ${table} VALUES(            \
		\"${event_prefix}\",                        \
		FROM_UNIXTIME(${begin}/1000),               \
		FROM_UNIXTIME(${end}/1000),                 \
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

write_record 'event_jitter'
