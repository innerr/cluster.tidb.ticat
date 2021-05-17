set -euo pipefail

env_file="${1}/env"
shift
env=`cat "${env_file}"`

user="${1}"

name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
if [ -z "${name}" ]; then
	echo "[:(] no env val 'tidb.cluster'" >&2
	exit 1
fi

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
mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
if [ "${?}" != 0 ]; then
	echo "[:(] access mysql ${host}:${port} failed" >&2
	exit 1
fi

echo "mysql.host	${host}" >> "${env_file}"
echo "mysql.port	${port}" >> "${env_file}"
echo "mysql.user	${user}" >> "${env_file}"
echo "[:)] host:port verify succeeded, set to env:"
echo "    - mysql.host = ${host}"
echo "    - mysql.port = ${port}"
echo "    - mysql.user = ${user}"
