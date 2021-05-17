set -euo pipefail

env=`cat ${1}/env`
shift

host=`echo "${env}" | grep '^mysql.host' | awk '{print $2}'`
port=`echo "${env}" | grep '^mysql.port' | awk '{print $2}'`
user=`echo "${env}" | grep '^mysql.user' | awk '{print $2}'`

if [ -z "${host}" ]; then
	echo "[:(] no env val 'mysql.host'" >&2
	exit 1
fi
if [ -z "${port}" ]; then
	echo "[:(] no env val 'mysql.port'" >&2
	exit 1
fi

mysql -h "${host}" -P "${port}" -u "${user}"
