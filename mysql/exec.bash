set -euo pipefail

env=`cat ${1}/env`
shift

query="${1}"
db="${2}"
user="${3}"
fmt="${4}"
warn="${5}"

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

if [ "${warn}" == 'true' ] || [ "${warn}" == 'on' ] || [ "${warn}" == '1' ]; then
	warn=' --show-warnings'
else
	warn=''
fi

host=`echo "${env}" | grep 'mysql.host' | awk '{print $2}'`
port=`echo "${env}" | grep 'mysql.port' | awk '{print $2}'`

mysql -h "${host}" -P "${port}" -u root --comments${db}${fmt}${warn} -e "${query}"
