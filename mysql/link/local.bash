set -uo pipefail

env_file="${1}/env"
shift

user="${1}"
host="${2}"

ports=(4000 3306)
for port in ${ports[@]}; do
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
	if [ "${?}" == 0 ]; then
		echo "mysql.host	${host}" >> "${env_file}"
		echo "mysql.port	${port}" >> "${env_file}"
		echo "mysql.port	${user}" >> "${env_file}"
		echo "[:)] find mysql succeeded, set to env:"
		echo "    - mysql.host = ${host}"
		echo "    - mysql.port = ${port}"
		echo "    - mysql.user = ${user}"
		exit
	fi
done

echo "[:(] find mysql host/port failed" >&2
exit 1
