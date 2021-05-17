set -euo pipefail

env_file="${1}/env"
shift
env=`cat "${env_file}"`

yaml="${1}"
name="${2}"
ver="${3}"

confirm=`echo "${env}" | { grep '^tidb.op.confirm' || test $? = 1; } | awk '{print $2}'`
if [ -z "${confirm}" ]; then
	confirm="${4}"
	echo "[:-] got confirm flag '${confirm}' from arg"
else
	echo "[:-] got confirm flag '${confirm}' from env"
fi

if [ -z "${yaml}" ]; then
	echo "[:-] no arg 'topology-name', alias 'yaml|yam|path|file|f|F|p|P|y|Y'" >&2
	yaml=`echo "${env}" | { grep '^tidb.tiup.yaml' || test $? = 1; } | awk '{print $2}'`
	if [ -z "${yaml}" ]; then
		echo "    [:(] no env val 'tidb.tiup.yaml'" >&2
		exit 1
	else
		echo "    [:)] got it from env val 'tidb.tiup.yaml'"
	fi
fi

if [ -z "${name}" ]; then
	echo "[:-] no arg 'cluster-name', alias 'cluster|name|n|N'" >&2
	name=`echo "${env}" | { grep '^tidb.cluster' || test $? = 1; } | awk '{print $2}'`
	if [ -z "${name}" ]; then
		echo "    [:(] no env val 'tidb.cluster'" >&2
		exit 1
	else
		echo "    [:)] got it from env val 'tidb.cluster'"
	fi
fi

if [ "${confirm}" == 'true' ] || [ "${confirm}" == 'on' ] || [ "${confirm}" == '1' ] || [ "${confirm}" == 'yes' ]; then
	confirm_str=''
else
	# skip confirm
	confirm_str=' --yes'
fi

tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm_str}

echo "tidb.cluster	${name}" >> "${env_file}"
echo "tidb.version	${ver}" >> "${env_file}"
echo "tidb.tiup.yaml	${yaml}" >> "${env_file}"
echo "tidb.op.confirm	${confirm}" >> "${env_file}"
echo "[:)] deploy cluster succeeded, set to env:"
echo "    - tidb.cluster = ${name}"
echo "    - tidb.version = ${ver}"
echo "    - tidb.tiup.yaml = ${yaml}"
echo "    - tidb.op.confirm = ${confirm}"
