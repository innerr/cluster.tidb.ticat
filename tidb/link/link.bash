set -euo pipefail

env_file="${1}/env"
shift

name="${1}"
verify="${2}"

if [ -z "${name}" ]; then
	echo "[:(] no arg 'cluster-name', alias 'cluster|name|n|N'" >&2
	exit 1
fi

if [ "${verify}" == 'true' ] || [ "${verify}" == 'on' ] || [ "${verify}" == '1' ] || [ "${verify}" == 'yes' ]; then
	tiup cluster display "${name}" 1>/dev/null 2>&1
	if [ "${?}" == 0 ]; then
		echo "tidb.cluster	${name}" >> "${env_file}"
		echo "[:)] verify cluster name succeeded, set to env:"
		echo "    - tidb.cluster = ${name}"
	else
		echo "[:(] verify cluster '${name}' failed, maybe it's a wrong name" >&2
		exit 1
	fi
else
	echo "tidb.cluster	${name}" >> "${env_file}"
	echo "[:)] set env:"
	echo "    - tidb.cluster = ${name}"
fi
