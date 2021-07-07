set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env_file="${1}/env"
env=`cat "${env_file}"`
shift

user=`must_env_val "${env}" 'mysql.user'`
name=`must_env_val "${env}" 'tidb.cluster'`

shift
verify=`to_true "${1}"`

tidbs=`must_cluster_tidbs "${name}"`
cnt=`echo "${tidbs}" | wc -l | awk '{print $1}'`
if [ "${cnt}" != 1 ]; then
	echo "[:-] more than 1 tidb found(${cnt}) in cluster '${name}', select the first one" >&2
fi

tidb=`echo "${tidbs}" | head -n 1`
host=`echo "${tidb}" | awk -F ':' '{print $1}'`
port=`echo "${tidb}" | awk -F ':' '{print $2}'`

if [ "${verify}" == 'true' ]; then
	verify_mysql_timeout "${env_file}" "${host}" "${port}" "${user}" 16
	echo "[:)] user@host:port verify succeeded, set to env:"
else
	echo "[:)] user@host:port is not verified, set to env:"
fi

echo "mysql.host=${host}" >> "${env_file}"
echo "mysql.port=${port}" >> "${env_file}"
echo "mysql.user=${user}" >> "${env_file}"
echo "    - mysql.host = ${host}"
echo "    - mysql.port = ${port}"
echo "    - mysql.user = ${user}"
