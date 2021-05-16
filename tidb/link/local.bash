set -euo pipefail

env="${1}/env"
shift

host=127.0.0.1
port=4000
user=root
db=test
mysql -h ${host} -P ${port} -u ${user} --database=${db} -e "show databases" >/dev/null

if [ "${?}" == 0 ]; then
	echo "mysql.host	${host}" >> "${env}"
	echo "mysql.port	${port}" >> "${env}"
fi
