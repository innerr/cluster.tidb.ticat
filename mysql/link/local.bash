set -uo pipefail

env="${1}/env"
shift

user="${1}"
host="${2}"

ports=(4000 3306)
for port in ${ports[@]}; do
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
	if [ "${?}" == 0 ]; then
		echo "mysql.host	${host}" >> "${env}"
		echo "mysql.port	${port}" >> "${env}"
		echo "find mysql succeeded, set to env:"
		echo "    - mysql.host = ${host}"
		echo "    - mysql.port = ${port}"
		exit
	fi
done

echo "find mysql host/port failed" >&2
exit 1
