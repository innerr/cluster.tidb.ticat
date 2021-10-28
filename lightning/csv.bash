set -euo pipefail

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../helper/helper.bash"

env=`cat "${1}/env"`
shift

name=`must_env_val "${env}" 'tidb.cluster'`
export pd=`must_cluster_pd "${name}"`
tmp_dir=`must_env_val "${env}" 'lightning.tmp-dir'`
export src_dir=`must_env_val "${env}" 'lightning.data-source-dir'`

uuid=`uuidgen`

conf_log_dir="/tmp/lightning-csv-${uuid}"
mkdir -p "${conf_log_dir}"
conf_file="${conf_log_dir}/lightning-csv.toml"
export log_file="${conf_log_dir}/lightning-csv.log"
echo "Log file will be at ${log_file}"

export sorted_kv_dir="${tmp_dir}/sorted-kv-dir-${uuid}"
mkdir -p "${sorted-kv-dir}"

export host=`must_env_val "${env}" 'mysql.host'`
export port=`must_env_val "${env}" 'mysql.port'`
export user=`must_env_val "${env}" 'mysql.user'`

export checksum=`must_env_val "${env}" 'lightning.checksum'`

tmpl="${here}/lightning-csv.toml.tmpl"
envsubst < "${tmpl}" > "${conf_file}"
echo "Config file will be at ${conf_file}"

tidb-lightning -config "${conf_file}"
