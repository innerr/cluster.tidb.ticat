set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

session="${1}"
env=`cat "${session}/env"`

host=`env_val "${env}" 'bench.meta.host'`
if [ -z "${host}" ]; then
	if [ -f "${session}/metrics" ]; then
		cat "${session}/metrics"
	else
		echo "[:(] can't find meta db from env, and session file-record also not exists" >&2
	fi
	exit
fi

port=`must_env_val "${env}" 'bench.meta.port'`
db=`must_env_val "${env}" 'bench.meta.db-name'`

has_metrics=`mysql -h "${host}" -P "${port}" -u root --database="${db}" -e "show tables" | { grep metrics || test $? = 1; }`
if [ -z "${has_metrics}" ]; then
	exit
fi

run_begin=`env_val "${env}" 'bench.run.begin'`
if [ -z "${run_begin}" ]; then
	query="SELECT * FROM metrics"
else
	bench_begin=`env_val "${env}" 'bench.begin'`
	if [ -z "${bench_begin}" ]; then
		query="SELECT * FROM metrics"
	else
		query="SELECT * FROM metrics WHERE bench_begin=FROM_UNIXTIME(${bench_begin})"
		echo "${query}"
	fi
fi

mysql -h "${host}" -P "${port}" -u root --database="${db}" -e "${query}"
