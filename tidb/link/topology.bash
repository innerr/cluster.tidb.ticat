set -euo pipefail

env_file="${1}/env"
shift

yaml="${1}"
if [ -z "${yaml}" ]; then
	echo "[:(] no arg 'topology-file-or-predefined-name', alias 'topology|yaml|yam|name|file|path|p|P|f|F|n|N|y|Y'" >&2
	exit 1
fi

if [ ! -f "${yaml}" ]; then
	here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
	file="${here}/topologies/${yaml}.yaml"
	if [ ! -f "${file}" ]; then
		echo "[:(] topology file or predifined name not found for '${yaml}'" >&2
		exit 1
	else
		yaml="${file}"
	fi
fi

echo "tidb.tiup.yaml	${yaml}" >> "${env_file}"
echo "[:)] set topology file path to env:"
echo "    - tidb.tiup.yaml = ${yaml}"
