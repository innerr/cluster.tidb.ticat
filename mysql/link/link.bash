set -uo pipefail

env_file="${1}/env"
shift

host="${1}"
port="${2}"
user="${3}"

if [ -z "${port}" ]; then
	ports=(4000 3306)
	for p in ${ports[@]}; do
		mysql -h "${host}" -P "${p}" -u "${user}" -e "show databases" >/dev/null 2>&1
		if [ "${?}" == 0 ]; then
			port="${p}"
			break
		fi
	done
fi

if [ -z "${port}" ]; then
	echo "[:(] find mysql host/port failed" >&2
	exit 1
fi

echo "mysql.host	${host}" >> "${env_file}"
echo "mysql.port	${port}" >> "${env_file}"
echo "mysql.user	${user}" >> "${env_file}"
echo "[:)] find mysql succeeded, set to env:"
echo "    - mysql.host = ${host}"
echo "    - mysql.port = ${port}"
echo "    - mysql.user = ${user}"
