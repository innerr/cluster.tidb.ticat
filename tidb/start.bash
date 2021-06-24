set -euo pipefail

env_file="${1}/env"
env=`cat "${env_file}"`
here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/../utils/base.bash" "${env}"

name=`must_env_val "${env}" 'tidb.cluster'`
tiup cluster start "${name}"

shift
user="${1}"

tidbs=`tiup cluster display "${name}" 2>/dev/null | { grep '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | awk '{if ($2=="tidb") print $1}'`
if [ -z "${tidbs}" ]; then
	echo "[:(] no tidb found in cluster '${name}'" >&2
	exit 1
fi

cnt=`echo "${tidbs}" | wc -l | awk '{print $1}'`
if [ "${cnt}" != 1 ]; then
	echo "[:-] more than 1 tidb found(${cnt}) in cluster '${name}', select the first one" >&2
fi

tidb=`echo "${tidbs}" | head -n 1`
host=`echo "${tidb}" | awk -F ':' '{print $1}'`
port=`echo "${tidb}" | awk -F ':' '{print $2}'`

set +e
for ((i=0; i < 16; i++)); do
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" #>/dev/null 2>&1
	if [ "${?}" == 0 ]; then
		echo "mysql.host	${host}" >> "${env_file}"
		echo "mysql.port	${port}" >> "${env_file}"
		echo "mysql.user	${user}" >> "${env_file}"
		echo "[:)] host:port verify succeeded, set to env:"
		echo "    - mysql.host = ${host}"
		echo "    - mysql.port = ${port}"
		echo "    - mysql.user = ${user}"
		exit 0
	fi
	sleep 1
	echo "[:-] verifying mysql address '${host}:${port}'"
done

echo "[:(] access mysql ${host}:${port} failed" >&2
exit 1
