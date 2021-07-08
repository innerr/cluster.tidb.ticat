. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/ticat.helper.bash/helper.bash"

function cluster_meta()
{
	local name="${1}"
	tiup cluster list 2>/dev/null | \
		{ grep -v 'PrivateKey$' || test $? = 1; } | \
		{ grep -v '\-\-\-\-\-\-\-$' || test $? = 1; } | \
		{ grep "^${name} " || test $? = 1; }
}

function cluster_exist()
{
	local name="${1}"
	local meta=`cluster_meta ${name}`
	if [ -z "${meta}" ]; then
		echo "false"
	else
		echo "true"
	fi
}

function must_cluster_exist()
{
	local name="${1}"
	meta=`cluster_meta ${name}`
	if [ -z "${meta}" ]; then
		echo "[:(] cluster name '${name}' not exists" >&2
		exit 1
	fi
}

function confirm_str()
{
	local env="${1}"
	local confirm=`must_env_val "${env}" 'tidb.op.confirm'`
	local is_false=`to_false "${confirm}"`
	if [ "${is_false}" != 'false' ]; then
		echo ''
	else
		# skip confirm
		echo ' --yes'
	fi
}

function verify_mysql()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	set +e
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
	local ret_code="${?}"
	set -e
	if [ "${ret_code}" != 0 ]; then
		echo "[:(] access mysql '${user}@${host}:${port}' failed" >&2
		exit 1
	fi
}

function cluster_tidbs()
{
	local name="${1}"
	set +e
	local tidbs=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="tidb") print $1}'`
	set -e
	echo "${tidbs}"
}

function must_cluster_tidbs()
{
	local name="${1}"
	local tidbs=`cluster_tidbs "${name}"`
	if [ -z "${tidbs}" ]; then
		echo "[:(] no tidb found in cluster '${name}'" >&2
		exit 1
	fi
	echo "${tidbs}"
}

function verify_mysql_timeout()
{
	local host="${1}"
	local port="${2}"
	local user="${3}"
	local timeout="${4}"

	for ((i=0; i < ${timeout}; i++)); do
		set +e
		mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
		if [ "${?}" == 0 ]; then
			set -e
			return
		fi
		sleep 1
		echo "[:-] verifying mysql address '${user}@${host}:${port}'"
	done

	echo "[:(] access mysql '${user}@${host}:${port}' failed" >&2
	exit 1
}

function config_mysql()
{
	local env_file="${1}"
	local host="${2}"
	local port="${3}"
	local user="${4}"
	echo "[:)] setup mysql access to env" >&2
	echo "mysql.host=${host}" >> "${env_file}"
	echo "mysql.port=${port}" >> "${env_file}"
	echo "mysql.user=${user}" >> "${env_file}"
	echo "    - mysql.host = ${host}"
	echo "    - mysql.port = ${port}"
	echo "    - mysql.user = ${user}"
}
