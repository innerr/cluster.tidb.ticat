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
