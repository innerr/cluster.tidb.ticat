set -uo pipefail

env_file="${1}/env"
shift
env=`cat ${env_file}`

yaml="${1}"
name="${2}"
ver="${3}"
confirm="${4}"

if [ -z "${yaml}" ]; then
	echo "[:(] no arg 'topology-name', alias 'yaml|yam|path|file|f|F|p|P|y|Y'" >&2
	echo "    [:-] trying to get it from env val 'tidb.tiup.yaml'"
	yaml=`echo "${env}" | grep '^tidb.tiup.yaml' | awk '{print $2}'`
	if [ -z "${yaml}" ]; then
		echo "    [:(] env val not found" >&2
		exit 1
	else
		echo "    [:)] succeeded"
	fi
fi

if [ -z "${name}" ]; then
	echo "[:(] no arg 'cluster-name', alias 'cluster|name|n|N'" >&2
	echo "    [:-] trying to get it from env val 'tidb.cluster'"
	name=`echo "${env}" | grep '^tidb.cluster' | awk '{print $2}'`
	if [ -z "${name}" ]; then
		echo "    [:(] env val not found" >&2
		exit 1
	else
		echo "    [:)] succeeded"
	fi
fi

if [ "${confirm}" == 'true' ] || [ "${confirm}" == 'on' ] || [ "${confirm}" == '1' ] || [ "${confirm}" == 'yes' ]; then
	confirm=''
else
	# skip confirm
	confirm=' --yes'
fi

set -e
tiup cluster deploy "${name}" "${ver}" "${yaml}"${confirm}

echo "tidb.cluster	${name}" >> "${env_file}"
echo "tidb.version	${ver}" >> "${env_file}"
echo "tidb.tiup.yaml	${yaml}" >> "${env_file}"
echo "[:)] deploy cluster succeeded, set to env:"
echo "    - tidb.cluster = ${name}"
echo "    - tidb.version = ${ver}"
echo "    - tidb.tiup.yaml = ${yaml}"
