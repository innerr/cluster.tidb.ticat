function env_val()
{
	local env="${1}"
	local key="${2}"
	local val=`echo "${env}" | { grep "^${key}" || test $? = 1; } | awk '{print $2}'`
	echo "${val}"
}

function must_env_val()
{
	local env="${1}"
	local key="${2}"
	local val=`echo "${env}" | { grep "^${key}" || test $? = 1; } | awk '{print $2}'`
	if [ -z "${val}" ]; then
		echo "[:(] no env val '${key}'" >&2
		exit 1
	fi
	echo "${val}"
}

function cluster_meta()
{
	local name="${1}"
	tiup cluster list 2>/dev/null | \
		{ grep -v 'PrivateKey$' || test $? = 1; } | \
		{ grep -v '\-\-\-\-\-\-\-$' || test $? = 1; } | \
		{ grep "${name}" || test $? = 1; }
}

function confirm_str()
{
	local env="${1}"
	local confirm=`env_val "${env}" 'tidb.op.confirm'`
	if [ "${confirm}" != 'false' ]; then
		echo ''
	else
		# skip confirm
		echo ' --yes'
	fi
}

function verify_mysql()
{
	local env_file="${1}"
	local host="${2}"
	local port="${3}"
	local user="${4}"

	for ((i=0; i < 16; i++)); do
		set +e
		mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
		if [ "${?}" == 0 ]; then
			echo "mysql.host	${host}" >> "${env_file}"
			echo "mysql.port	${port}" >> "${env_file}"
			echo "mysql.user	${user}" >> "${env_file}"
			echo "[:)] host:port verify succeeded, set to env:"
			echo "    - mysql.host = ${host}"
			echo "    - mysql.port = ${port}"
			echo "    - mysql.user = ${user}"
			set -e
			return 0
		fi
		sleep 1
		echo "[:-] verifying mysql address '${host}:${port}'"
	done

	echo "[:(] access mysql '${host}:${port}' failed" >&2
	return 1
}
