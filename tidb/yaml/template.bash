set -euo pipefail

env_file="${1}/env"
shift

yaml="${1}"
if [ -z "${yaml}" ]; then
	echo "[:(] no arg 'predefined-name', alias 'name|n|N'" >&2
	exit 1
fi

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
file="${here}/${yaml}.yaml"
if [ ! -f "${file}" ]; then
	echo "[:(] topology file not found for predifined-name '${yaml}'" >&2
	exit 1
else
	yaml="${file}"
fi

echo "tidb.tiup.yaml	${yaml}" >> "${env_file}"
echo "[:)] set topology file path to env:"
echo "    - tidb.tiup.yaml = ${yaml}"
