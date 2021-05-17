set -euo pipefail

env=`cat ${1}/env`
shift

host=`echo "${env}" | { grep '^mysql.host' || test $? = 1; } | awk '{print $2}'`
port=`echo "${env}" | { grep '^mysql.port' || test $? = 1; } | awk '{print $2}'`
user=`echo "${env}" | { grep '^mysql.user' || test $? = 1; } | awk '{print $2}'`

if [ -z "${host}" ]; then
	echo "[:(] no env val 'mysql.host'" >&2
	exit 1
fi
if [ -z "${port}" ]; then
	echo "[:(] no env val 'mysql.port'" >&2
	exit 1
fi

query="${1}"
db="${2}"
fmt="${3}"
warn="${4}"

if [ -z "${query}" ]; then
	echo "[:(] no arg 'query', alias 'q|Q'" >&2
	exit 1
fi

if [ ! -z "${db}" ]; then
	db=" --database=${db}"
else
	db=''
fi

if [ "${fmt}" == 'v' ]; then
	fmt=' --vertical'
fi
if [ "${fmt}" == 'tab' ]; then
	fmt=' --batch'
fi
if [ "${fmt}" == 't' ]; then
	fmt=' --table'
fi
if [ -z "${fmt}" ]; then
	fmt=' --table'
fi

if [ "${warn}" == 'true' ] || [ "${warn}" == 'on' ] || [ "${warn}" == '1' ] || [ "${warn}" == 'yes' ]; then
	warn=' --show-warnings'
else
	warn=''
fi

mysql -h "${host}" -P "${port}" -u root --comments${db}${fmt}${warn} -e "${query}"
